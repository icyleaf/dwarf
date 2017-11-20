require "http/server/handler"
require "./ext/*"

module Dwarf
  class Handler
    include HTTP::Handler

    def initialize(@manager : Dwarf::Manager)
    end

    def call(context)
      context.dwarf = Dwarf::Proxy.new(context, @manager) unless context.dwarf?
      call_next(context)
    end
  end
end
