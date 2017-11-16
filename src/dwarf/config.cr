module Dwarf
  class Config
    record Type, value : String | Bool | Hash(String, Type) | Array(Type) | Nil

    @stores = {} of String => Type

    def initialize(options = {} of String => Type)
      @stores.merge!(options)
      @stores["default_scope"] ||= Type.new("all")
      @stores["scope_defaults"] ||= Type.new({} of String => Type)
      @stores["default_strategies"] ||= Type.new({} of String => Type)
      @stores["intercept_401"] = Type.new(true) unless @stores.has_key?("intercept_401")
      @stores["silence_missing_strategies"] = Type.new(false)
    end

    def silence_missing_strategies!
      @stores["silence_missing_strategies"] = Type.new(true)
    end

    def silence_missing_strategies?
      !!@stores["silence_missing_strategies"].value.as(Bool)
    end

    def [](key)
      @stores[key]
    end

    def []=(key, value)
      @stores[key] = value
    end

    def default_strategies(strategies _strategies : Array(String), scope : String = "all")
      _strategies = _strategies.each_with_object([] of Type) do |s, obj|
        obj << Type.new(s)
      end

      hash = @stores["default_strategies"].value.as(Hash(String, Type))
      hash[scope] = Type.new(_strategies)
    end

    def register_strategy(name : String, strategy : Dwarf::Strategies::Base)
      strategies.register(name, strategy)
    end

    # def scope_defaults(scope : String, strategies _strategies : Array(String)? = nil)
    #   if _strategies
    #     default_strategies(_strategies, scope: scope)
    #   end

    #   # @stores["asdfasdf"] = Type.new("12")

    #   # if opts.empty?
    #   #   self[:scope_defaults][scope] || {}
    #   # else
    #   #   self[:scope_defaults][scope] ||= {}
    #   #   self[:scope_defaults][scope].merge!(opts)
    #   # end
    # end

    def strategies
      Dwarf::Strategies
    end

    def serialize_into_session(*args, &block)
      Dwarf::Manager.serialize_into_session(*args, &block)
    end

    def serialize_from_session(*args, &block)
      Dwarf::Manager.serialize_from_session(*args, &block)
    end

    macro hash_property(*names)
      {% for name in names %}
      def {{ name.id }} : Type
        @stores[{{ name.id.stringify }}].as(Type)
      end

      def {{ name.id }}=(value) : Type
        @stores[{{ name.id.stringify }}] = Type.new(value)
      end
      {% end %}
    end

    hash_property "failure_app", "default_scope", "intercept_401"
  end
end
