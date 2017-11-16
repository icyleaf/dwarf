module Dwarf
  class Proxy
    getter context, manager

    getter config : Dwarf::Config

    getter strategies : Hash(String, Hash(String, Dwarf::Strategies::Base?))

    getter winning_strategies : Hash(String, Dwarf::Strategies::Base)
    property winning_strategy : Dwarf::Strategies::Base?

    getter session_serializer

    delegate default_strategies, to: @config

    def initialize(@context : HTTP::Server::Context, @manager = Dwarf::Manager.new)
      @config = @manager.config
      @locked = false

      @users = {} of String => JSON::Any
      @strategies = {} of String => Hash(String, Dwarf::Strategies::Base?)
      @winning_strategies = {} of String => Dwarf::Strategies::Base
      @session_serializer = Dwarf::SessionSerializer.new(@context)
    end

    def lock!
      @locked = true
    end

    def authenticate!(scope : String? = nil)
      authenticate(scope, true)
    end

    def authenticate(scope : String? = nil, raise_exception = false) : JSON::Any?
      if user = perform_authentication(scope)
        return user
      end

      raise Dwarf::NotAuthenticated.new if raise_exception
    end

    def authenticate?(scope : String? = nil, &block)
      yield authenticate?(scope)
    end

    def authenticate?(scope : String? = nil)
      !!authenticate(scope)
    end

    def set_user(user : JSON::Any, scope : String? = nil) : JSON::Any
      scope ||= retrieve_scope
      @users[scope] = user
    end

    def user(scope : String? = nil) : JSON::Any?
      scope ||= retrieve_scope

      @users[scope]?
    end

    private def perform_authentication(scope : String? = nil)
      scope ||= retrieve_scope
      run_strategies_for(scope)

      if (strategy = @winning_strategy) && strategy.successful?
        set_user(strategy.user, scope)
      end
    end

    # Run the strategies for a given scope
    private def run_strategies_for(scope)
      if (strategy = @winning_strategies[scope]?) && strategy.halted?
        return @winning_strategy = strategy
      end

      # Do not run any strategy if locked
      return if @locked

      defaults = @config["default_strategies"].value.as(Hash(String, Config::Type))
      strategies = (defaults[scope]? || defaults["all"]).value.as(Array)
      strategies.each do |name|
        if strategy = fetch_strategy(name.value.to_s, scope)
          strategy.context = @context
          next unless !strategy.performed? && strategy.valid?

          strategy.run!
          @winning_strategy = @winning_strategies[scope] = strategy
          break if strategy.halted?
        end
      end
    end

    private def retrieve_scope : String
      scope = @config.default_scope.value.as(String)
    end

    private def fetch_strategy(name : String, scope : String) : Dwarf::Strategies::Base?
      @strategies[scope] = {} of String => Dwarf::Strategies::Base? unless @strategies.has_key?(scope)
      @strategies[scope][name] = if strategy = Dwarf::Strategies[name]?
                                   strategy.dup
                                 elsif @config.silence_missing_strategies?
                                   nil
                                 else
                                   raise Dwarf::Error.new "Invalid strategy #{name}"
                                 end
    end
  end
end
