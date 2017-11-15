module Dwarf
  class Proxy
    include Dwarf::Mixins

    getter context, manager, config

    getter session_serializer

    delegate default_strategies, to: @config

    def initialize(@context : HTTP::Server::Context, @manager : Dwarf::Manager)
      @config = @manager.config.dup
      @locked = false

      @session_serializer = Dwarf::SessionSerializer.new(@env)
    end

    def lock!
      @locked = true
    end
  end
end
