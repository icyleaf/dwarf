class HTTP::Server
  class Context
    property session = {} of String => String

    property! dwarf : Dwarf::Proxy?
  end
end
