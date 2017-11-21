module Dwarf::Strategies
  abstract class Base
    delegate :request, to: context

    def params
      context.params
    end
  end
end
