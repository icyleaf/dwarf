module Dwarf
  class Config < Hash(String, String)
    def initialize(options = {} of String => String)
      super(nil)
      merge!(options)
      self["default_scope"] = "default"
    end

    def default_strategies
      self["default_scope"]
    end

    def strategies
      Dwarf::Strategies
    end

    def serialize_into_session(*args, &block)
      Dwarf::Manager.serialize_into_session(*args, &block)
    end

    def serialize_from_session(*args, &block)
      Dwarf::Manager.serialize_from_session(*args, &block)
    end
  end
end
