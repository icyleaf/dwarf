require "./dwarf/*"

module Dwarf
  class Error < Exception; end

  class NotAuthenticated < Error; end
end
