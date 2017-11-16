require "http/server/handler"
require "./ext/*"

module Dwarf
  class Manager
    extend Dwarf::Hooks
    include HTTP::Handler

    property config : Dwarf::Config

    def self.new(options = {} of String => Dwarf::Config::Type)
      new(options) do |config|
        # do nothing
      end
    end

    def initialize(options = {} of String => Dwarf::Config::Type, &block : Dwarf::Config -> _)
      # default_strategies = options.delete("default_strategies")
      @config = Dwarf::Config.new(options)

      yield @config
      # @config.default_strategies(default_strategies) if default_strategies
    end

    def call(context)
      context.dwarf = Proxy.new(context, self) unless context.dwarf?

      # return call_next(context) if (dwarf = context.dwarf) && dwarf.manager != self
      call_next(context)
    end
  end
end
