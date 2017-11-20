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

    def self.clear!
      @@strategies.clear
    end
  end
end
