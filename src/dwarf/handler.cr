require "http/server/handler"
require "./ext/*"

module Dwarf
  # Handler of HTTP Server
  class Handler
    include HTTP::Handler

    def initialize(@manager : Dwarf::Manager)
    end

    # Invoke the application guarding for raise Dwarf::Error.
    # If this is downstream from another warden instance, don't do anything.
    def call(context)
      context.dwarf = Dwarf::Proxy.new(context, @manager) unless context.dwarf?
      call_next(context)
    # rescue e : Dwarf::Error
    #   # TODO:
    end
  end
end
