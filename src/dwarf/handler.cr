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
        call_redirect(context, dwarf.headers, dwarf.message)
      when Dwarf::Strategies::Result::Custom
        call_custom_response(context, dwarf.custom_response.not_nil!)
      else
        raise Dwarf::Error.new "Not match result"
      end
    end

    private def call_redirect(context, headers : HTTP::Headers? = nil, body : String? = nil)
      body ||= "You are being redirected to #{headers.not_nil!["Location"]}"
      perform_response(context, body, 401, headers)
    end

    private def call_custom_response(context, response : Dwarf::Strategies::Response)
      perform_response(context, response.body, response.status_code, response.headers)
    end

    private def perform_response(context, body : String, status_code : Int32 = 200, headers : HTTP::Headers? = nil)
      context.response.status_code status_code
      context.response.headers.merge! headers if headers
      context.response.print body
      context
    end
  end
end
