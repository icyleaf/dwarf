module Dwarf
  class Manager
    def self.new(options = {} of String => Dwarf::Config::Type)
      new(options) do |config|
        # do nothing
      end
    end

    # Config
    property config : Dwarf::Config

    # handler of HTTP Server
    getter! handler : Dwarf::Handler

    # Initialize a manager. If a block is given, a `Dwarf::Config` is yielded so you can properly
    # configure the Dwarf::Manager.
    def initialize(options = {} of String => Dwarf::Config::Type, &block : Dwarf::Config -> _)
      @config = Dwarf::Config.new(options)
      @handler = Dwarf::Handler.new(self)

      yield @config
    end
  end
end
