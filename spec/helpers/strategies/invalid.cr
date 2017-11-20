private class InvalidStrategy < Dwarf::Strategies::Base
  def valid?
    false
  end

  def authenticate!; end
end

Dwarf::Strategies.register("invalid", InvalidStrategy.new)
