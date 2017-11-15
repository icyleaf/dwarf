module Dwarf::Strategies
  class Base
    include Dwarf::Mixins

    property user, message

    # property result, custom_response

    getter env, scope, status

    def initialize(@env : HTTP::Server::Context, @scope : Symbol? = nil)
      # @status = nil
      @headers = HTTP::Headers.new

      @halted = false
      @performed = false
    end
  end
end
