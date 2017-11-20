
require "spec2"
require "../src/dwarf"
require "./helpers/strategies/*"

def setup_dwarf_manager(&block : -> Dwarf::Manager)
  block.call
end

def setup_server(manager)
  server = HTTP::Server.new("127.0.0.1", 8765, [manager.handler]) do |context|
    context.response.content_type = "text/plain"

    if context.request.method == "POST" && context.request.path == "/authenticate"
      context.dwarf.authenticate!

      if user = context.dwarf.user
        context.response.print "Logged in, hello #{user["name"]}!"
      else
        context.response.print "Auth request!"
      end
    else
      context.response.print "Hello world!"
    end
  end

  spawn do
    puts "Listening on http://127.0.0.1:8765"
    server.listen
  end
end
