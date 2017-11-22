class HTTP::Server::Context
  property! dwarf : Dwarf::Proxy

  # Proxy of dwarf
  def dwarf
    @dwarf ||= Dwarf::Proxy.new(self)
    @dwarf.not_nil!
  end
end
