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

    # Clear the cache of performed strategies so far. Warden runs each
    # strategy just once during the request lifecycle. You can clear the
    # strategies cache if you want to allow a strategy to be run more than
    # once.
    #
    # ```
    # # Clear all strategies for the configured default_scope
    # context.dwarf.clear_strategies_cache!
    # # Clear all strategies for the :admin scope
    # context.dwarf.clear_strategies_cache!(scope: "admin")
    #
    # # Clear password strategy for the :admin scope
    # context.dwarf.clear_strategies_cache!(scope: "admin", strategies: ["password"])
    # ```
    def clear_strategies_cache!(scope : String? = nil, strategies = [] of String)
      scope ||= retrieve_scope

      @winning_strategies.delete(scope)
      @strategies[scope].each do |k, v|
        v.clear! if strategies.empty? || strategies.include?(k)
      end
    end

    # Locks the proxy so new users cannot authenticate during the
    # request lifecycle. This is useful when the request cannot
    # be verified (for example, using a CSRF verification token).
    # Notice that already authenticated users are kept as so.
    def lock!
      @locked = true
    end

    # Same API as `authenticated?` but returns a block
    def authenticate?(scope : String? = nil, strategies = [] of String, &block)
      yield authenticate?(scope, strategies)
    end

    # Same API as `authenticated`, but returns a boolean instead of a user.
    # The difference between this method (authenticate?) and authenticated?
    # is that the former will run strategies if the user has not yet been
    # authenticated, and the second relies on already performed ones.
    def authenticate?(scope : String? = nil, strategies = [] of String)
      !!authenticate(scope, strategies)
    end

    # The same as `authenticate` except on failure it will throw an :warden symbol causing the request to be halted
    # and rendered through the failure_app
    #
    # ```
    # context.dwarf.authenticate!(:password, :scope => :publisher) # raise a Dwarf::Error if it cannot authenticate
    # ```
    def authenticate!(scope : String? = nil, strategies = [] of String)
      authenticate(scope, strategies, raise_exception: true)
    end

    # Run the authentication strategies for the given strategies.
    # If there is already a user logged in for a given scope, the strategies are not run
    # This does not halt the flow of control and is a passive attempt to authenticate only
    # When scope is not specified, the default_scope is assumed.
    #
    # ```
    # context.dwarf.authenticate("")
    # ```
    def authenticate(scope : String? = nil, strategies = [] of String, raise_exception = false) : JSON::Any?
      if user = perform_authentication(scope, strategies)
        return user
      end

      raise Dwarf::NotAuthenticated.new(scope: scope) if raise_exception
    end

    # Manually set the user auth proxy
    # TODO: store it into session
    def set_user(user : JSON::Any, scope : String? = nil) : JSON::Any
      scope ||= retrieve_scope
      @users[scope] = user
    end

    # Provides access to the user json's object in a given scope for a request.
    # Will be nil if not logged in. Please notice that this method does not
    # perform strategies.
    #
    # ```
    # # get default user(without scope)
    # context.dwarf.user
    #
    # # with scope
    # context.dwarf.user("admin")
    # ```
    def user(scope : String? = nil) : JSON::Any?
      scope ||= retrieve_scope

      @users[scope]?
    end

    # TODO: dependence session
    def logout
    end

    # Proxy through to the winning strategy to get the result.
    def result
      (strategy = winning_strategy) && strategy.result
    end

    # Proxy through to the winning strategy to get the message that was generated.
    def message
      (strategy = winning_strategy) && strategy.message
    end

    # Proxy through to the winning strategy to get the headers that was generated.
    def headers
      (strategy = winning_strategy) && strategy.headers
    end

    # Proxy through to the winning strategy to get the status that was generated.
    def status
      (strategy = winning_strategy) && strategy.status
    end

    # Proxy through to the winning strategy to get the custom_response that was generated.
    def custom_response
      (strategy = winning_strategy) && strategy.custom_response
    end

    # Perform authentication
    private def perform_authentication(scope : String? = nil, strategies = [] of String)
      scope ||= retrieve_scope
      run_strategies_for(scope, strategies)

      if (strategy = @winning_strategy) && strategy.successful?
        set_user(strategy.user, scope)
      end
    end

    # Run the strategies for a given scope
    private def run_strategies_for(scope, strategies = [] of String)
      if (strategy = @winning_strategies[scope]?) && strategy.halted?
        return @winning_strategy = strategy
      end

      # Do not run any strategy if locked
      return if @locked

      if strategies.empty?
        defaults = @config["default_strategies"].value.as(Hash(String, Config::Type))
        strategies = (defaults[scope]? || defaults["all"]).value.as(Array)
      end

      strategies.each do |name|
        if strategy = fetch_strategy(name.is_a?(Config::Type) ? name.value.to_s : name.to_s, scope)
          strategy.context = @context
          next unless !strategy.performed? && strategy.valid?

          strategy.run!
          @winning_strategy = @winning_strategies[scope] = strategy
          break if strategy.halted?
        end
      end
    end

    # Fetches a default scope
    private def retrieve_scope : String
      scope = @config.default_scope.value.as(String)
    end

    # Fetches strategies and keep them in a hash cache.
    private def fetch_strategy(name : String, scope : String) : Dwarf::Strategies::Base?
      @strategies[scope] = {} of String => Dwarf::Strategies::Base? unless @strategies.has_key?(scope)
      @strategies[scope][name] = if strategy = Dwarf::Strategies[name]?
                                   strategy.dup
                                 elsif @config.silence_missing_strategies?
                                   nil
                                 else
                                   raise Dwarf::KeyError.new "Invalid strategy #{name}", scope
                                 end
    end
  end
end
