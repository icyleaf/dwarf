require "./dwarf/*"

module Dwarf
  class Error < Exception
    getter scope

    def initialize(@message : String? = nil, @scope : String? = nil)
    end
  end

  class KeyError < Error; end

  class NotAuthenticated < Error; end
end
