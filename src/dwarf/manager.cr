module Dwarf
  class Manager
    def self.new(options = {} of String => Dwarf::Config::Type)
      new(options) do |config|
        # do nothing
      end
    end

    property config : Dwarf::Config
    getter! handler : Dwarf::Handler

    def initialize(options = {} of String => Dwarf::Config::Type, &block : Dwarf::Config -> _)
      @config = Dwarf::Config.new(options)
      @handler = Dwarf::Handler.new(self)

      yield @config
    end
  end
end
