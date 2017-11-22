module Dwarf
  class Config
    record Type, value : String | Bool | Hash(String, Type) | Array(Type) | Nil

    @stores = {} of String => Type

    def initialize(options = {} of String => Type)
      @stores.merge!(options)
      @stores["default_scope"] ||= Type.new "default"
      @stores["default_strategies"] ||= Type.new({} of String => Type)

      # @stores["scope_defaults"] ||= Type.new({} of String => Type)
      @stores["intercept_401"] = Type.new(true) unless @stores.has_key?("intercept_401")
      @stores["silence_missing_strategies"] = Type.new false
    end

    # Set the default strategies to use.
    def default_strategies(strategies = [] of String, scope : String = "all") : Array(Type)
      hash = @stores["default_strategies"].value.as(Hash(String, Type))
      array = strategies.each_with_object([] of Type) do |strategy, obj|
        obj << Type.new(strategy)
      end

      hash[scope] = Type.new(array)
      hash[scope].value.as(Array) || array
    end

    # # A short hand way to set up a particular scope
    # def scope_defaults(scope : String, strategies = [] of String)
    #   unless strategies.empty?
    #     default_strategies(__strategies, scope: scope)
    #   end

    #   if strategies
    #     self["scope_defaults"][scope] || {}
    #   else
    #     self[:scope_defaults][scope] ||= {}
    #     self[:scope_defaults][scope].merge!(opts)
    #   end
    # end

    # Do not raise an error if a missing strategy is given.
    def silence_missing_strategies!
      @stores["silence_missing_strategies"] = Type.new true
    end

    # Checks if raise an error when missing strategy is given.
    def silence_missing_strategies?
      !!@stores["silence_missing_strategies"].value.as(Bool)
    end

    def [](key)
      @stores[key]
    end

    def []=(key, value)
      @stores[key] = Type.new value
    end

    # Quick accessor to strategies from manager
    def strategies
      puts "ddd"
      Dwarf::Strategies
    end

    # Register a strategy
    def register_strategy(name : String, strategy : Dwarf::Strategies::Base)
      strategies.register(name, strategy)
    end

    # def serialize_into_session(*args, &block)
    #   Dwarf::Manager.serialize_into_session(*args, &block)
    # end

    # def serialize_from_session(*args, &block)
    #   Dwarf::Manager.serialize_from_session(*args, &block)
    # end

    # Creates an property that simply sets and reads a key:
    macro hash_property(*names)
      {% for name in names %}
      def {{ name.id }} : Type
        @stores[{{ name.id.stringify }}].as(Type)
      end

      def {{ name.id }}=(value) : Type
        @stores[{{ name.id.stringify }}] = Type.new value
      end
      {% end %}
    end

    hash_property "failure_app", "default_scope", "intercept_401"
  end
end
