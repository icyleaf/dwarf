require "json"

module Dwarf::Strategies
  abstract class Base
    property result : Result
    property message : String?

    property! user : JSON::Any
    property! context : HTTP::Server::Context

    def initialize(@scope : String? = nil)
      @headers = HTTP::Headers.new
      @halted = false
      @performed = false
      @result = Result::None
    end

    def run!
      @performed = true
      authenticate!
      self
    end

    def performed? : Bool
      @performed
    end

    def halt!
      @halted = true
    end

    def halted?
      !!@halted
    end

    def successful?
      @result == Result::Success && !user.nil?
    end

    def success!(user : JSON::Any, message : String? = nil)
      success(user, message, halted: true)
    end

    def success(user : JSON::Any, message : String? = nil, halted = false)
      @halted = halted
      @user = user
      @message = message
      @result = Result::Success
    end

    def fail!(message = "Failed to Login")
      fail(message, halted: true)
    end

    def fail(message = "Failed to Login", halted = false)
      @halted = halted
      @message = message
      @result = Result::Failure
    end

    def errors
      @context.dwarf.errors
    end

    def clear!
      @performed = false
    end

    # def custom!(response)
    #   halt!
    #   @custom_response = response
    #   @result = Result::Custom
    # end

    abstract def valid? : String? | Bool

    # abstract def pass?

    abstract def authenticate!(scope : String? = nil, strategy : String? = nil)
  end
end
