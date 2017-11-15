require "http/server/handler"

module Dwarf
  class Manager
    extend Dwarf::Hooks
    include HTTP::Handler

    property config : Dwarf::Config

    def self.new(options = {} of String => String)
      new(options) do |config|
        # do nothing
      end
    end

    def initialize(options = {} of String => String, &block : -> Dwarf::Config)
      # default_strategies = options.delete("default_strategies")
      @config = Dwarf::Config.new(options)

      yield @config
      # @config.default_strategies(default_strategies) if default_strategies
    end

    def call(context)
      return next_call(context) if context.dwarf && context.dwarf.manager != self

      context.dwarf = Proxy.new(context, self)
    end
  end
end
