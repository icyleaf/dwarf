module Dwarf::Strategies
  abstract class Base
    delegate request, to: context

    def params
      if parser = request.param_parser
        parser.body
      else
        HTTP::Params.new
      end
    end
  end
end
