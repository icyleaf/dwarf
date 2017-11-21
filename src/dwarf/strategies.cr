require "./strategies/*"

module Dwarf
  module Strategies
    enum Result
      Success
      Failure
      Redirect
      Custom
      None
    end

    @@strategies = {} of String => Dwarf::Strategies::Base

    def self.register(name : String, strategy : Dwarf::Strategies::Base)
      return @@strategies[name] if @@strategies.has_key?(name) && @@strategies[name] == strategy

      @@strategies[name] = strategy
    end

    def self.[](name : String) : Dwarf::Strategies::Base
      @@strategies[name]
    end

    def self.[]?(name : String) : Dwarf::Strategies::Base?
      return nil unless @@strategies.has_key?(name)

      @@strategies[name]
    end

    def self.keys
      @@strategies.keys
    end

    def self.values
      @@strategies.values
    end

    def self.clear!
      @@strategies.clear
    end

    macro register(name, &block)
      class Dwarf::Strategies::{{ name.id.capitalize }}Strategy < Dwarf::Strategies::Base
        {{block.body}}
      end

      Dwarf::Strategies.register({{ name.id.downcase.stringify}}, Dwarf::Strategies::{{ name.id.capitalize }}Strategy.new)
    end
  end
end
