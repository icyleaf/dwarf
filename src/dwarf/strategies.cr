require "./strategies/*"

module Dwarf
  module Strategies
    # Result of authentincation
    enum Result
      Success
      Failure
      Redirect
      Custom
      None
    end

    @@strategies = {} of String => Dwarf::Strategies::Base

    # Add a strategy with given instanced strategy
    def self.register(name : String, strategy : Dwarf::Strategies::Base)
      return @@strategies[name] if @@strategies.has_key?(name) && @@strategies[name] == strategy

      @@strategies[name] = strategy
    end

    # Provides access to strategies by label
    def self.[](name : String) : Dwarf::Strategies::Base
      @@strategies[name]
    end

    # Same as `[]`, but returns nil if it was not exists
    def self.[]?(name : String) : Dwarf::Strategies::Base?
      return nil unless @@strategies.has_key?(name)

      @@strategies[name]
    end

    # Returns name of strategies
    def self.keys
      @@strategies.keys
    end

    # Returns instanced strageties
    def self.values
      @@strategies.values
    end

    # Clears all declared.
    def self.clear!
      @@strategies.clear
    end

    # Create a strategy, add and store it in a hash.
    macro register(name, &block)
      class Dwarf::Strategies::{{ name.id.capitalize }}Strategy < Dwarf::Strategies::Base
        {{block.body}}
      end

      Dwarf::Strategies.register({{ name.id.downcase.stringify}}, Dwarf::Strategies::{{ name.id.capitalize }}Strategy.new)
    end
  end
end
