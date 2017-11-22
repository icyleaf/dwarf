require "http/params"

module Dwarf
  module Mixins
    @request : HTTP::Request?

    def request
      if (req = @request) && req == context.request
        return req
      end

      @request = context.request
      @request.not_nil!
    end

    @params_parsed = false
    @params = HTTP::Params.new

    def params : HTTP::Params
      return @params if @params_parsed && @request == context.request

      @params_parsed = true
      @params = case request.headers["content_type"]
                when .includes?("multipart/form-data")
                  parse_multipart(request)
                else
                  parse_body(request.body)
                end
    end

    @files = {} of String => HTTP::FormData::Part

    def files
      @files
    end

    private def parse_body(body)
      raws = case body
             when IO
               body.gets_to_end
             when String
               body.to_s
             else
               ""
             end

      HTTP::Params.parse raws
    end

    private def parse_multipart(request) : HTTP::Params
      params = HTTP::Params.new

      HTTP::FormData.parse(request) do |part|
        next unless part

        name = part.name
        if filename = part.filename
          @files[name] = part
        else
          params.add name, part.body.gets_to_end
        end
      end

      params
    end
  end
end
