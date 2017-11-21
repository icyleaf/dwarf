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
    rescue e : Dwarf::NotAuthenticated
      process_unauthenticated(context, e.scope)
    end

    private def process_unauthenticated(context, scope : String? = nil)
      dwarf = context.dwarf
      scope ||= dwarf.config.default_scope.value.as(String)
      case dwarf.result
      when Dwarf::Strategies::Result::Redirect
        call_unauthenticated(context, dwarf.headers, dwarf.message)
      when Dwarf::Strategies::Result::Custom
        proxy.custom_response
      else
        raise Dwarf::Error.new "Not match result"
      end
    end

    private def call_unauthenticated(context, headers : HTTP::Headers? = nil, message : String? = nil)
      context.response.status_code = 401
      context.response.print message || "You are being redirected to "
    end
  end
end
