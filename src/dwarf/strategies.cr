require "./strategies/*"

module Dwarf
  module Strategies
    @strategies = {} of String => Dwarf::Strategies

    # def add(name, strategy = nil)
    #   strategy ||= Dwarf::Strategies::Base.new

    #   @strategies[name] = strategy
    # end

    def [](name)
      @strategies[name]
    end

    def self.clear!
      @strategies.clear
    end

    def self.hello
      "dddd"
    end
  end
end
