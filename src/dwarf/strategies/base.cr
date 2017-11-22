require "json"

module Dwarf::Strategies
  record Response, status_code : Int32, headers : HTTP::Headers, body : String

  abstract class Base
    property result : Result
    property! custom_response : Response
    property message : String?

    property! user : JSON::Any
    property! context : HTTP::Server::Context

    def initialize(@scope : String? = nil)
      @headers = HTTP::Headers.new
      @halted = false
      @performed = false
      @result = Result::None
    end

    abstract def valid? : String? | Bool

    abstract def authenticate!(scope : String? = nil, strategy : String? = nil)

    # A simple method to return from authenticate! if you want to ignore this strategy
    def pass; end

    # Returns if this strategy was already performed.
    def performed? : Bool
      @performed
    end

    # Cause the processing of the strategies to stop and cascade no further
    def halt!
      @halted = true
    end

    # Checks to see if a strategy was halted
    def halted?
      !!@halted
    end

    # Returns true only if the result is a success and a user was assigned.
    def successful?
      @result == Result::Success && !user.nil?
    end

    # Whenever you want to provide a user object as "authenticated" use the `success!` method.
    # This will halt the strategy, and set the user in the appropriate scope.
    # It is the "login" method
    def success!(user : JSON::Any, message : String? = nil)
      @halted = true
      @user = user
      @message = message
      @result = Result::Success
    end

    # This causes the strategy to fail.
    # It does not raise Dwarf::Error to drop the request out to the failure application
    # You must throw an :warden symbol somewhere in the application to enforce this
    # Halts the strategies so that this is the last strategy checked
    def fail!(message = "Failed to Login")
      fail(message, halted: true)
    end

    # Causes the strategy to fail, but not halt.
    # The strategies will cascade after this failure and warden will check the next strategy.
    # The last strategy to fail will have it's message displayed.
    def fail(message = "Failed to Login", halted = false)
      @halted = halted
      @message = message
      @result = Result::Failure
    end

    # Access to the errors object.
    # def errors
    #   @context.dwarf.errors
    # end

    # Marks this strategy as not performed.
    def clear!
      @performed = false
    end

    # Checks to see if a strategy should result in a permanent login
    # def store?
    #   true
    # end

    def headers(header = HTTP::Headers.new)
      @headers.merge! header
      @headers
    end

    # Causes the authentication to redirect.  An Dwarf::Error must be thrown to actually execute this redirect
    def redirect!(url, message : String? = nil, content_type = "text/plain", permanent = true)
      halt!

      headers["Content-Type"] = content_type
      headers["Location"] = String.build do |io|
        uri = url.dup
        uri = "/#{uri}" if !uri.starts_with?("http") && uri[0] != '/'
        io << uri
        io << "?" << params.to_s unless params.empty?
      end.to_s

      @status = permanent ? 301 : 302
      @message = message || "You are being redirected to #{headers["Location"]}"
      @result = Result::Redirect

      headers["Location"]
    end

    def custom!(body : String, status_code : Int32 = 200, headers = HTTP::Headers.new)
      halt!
      @custom_response ||= Response.new status_code, headers, body
      @result = Result::Custom
    end

    # The method that is called from above. This method calls the underlying authenticate! method
    protected def run!
      @performed = true
      authenticate!
      self
    end
  end
end
