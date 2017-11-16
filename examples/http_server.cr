require "./password_strategy"
require "../src/dwarf/services/http_server" # Change to "dwarf/services/http_server" in production
require "http/server"
require "http/client"

dwarf_manager = Dwarf::Manager.new do |config|
  config.register_strategy("password", PasswordStrategy.new)
  config.default_strategies(strategies: ["password"])
end

server = HTTP::Server.new("127.0.0.1", 8765, [dwarf_manager]) do |context|
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

sleep 1

r = HTTP::Client.post_form "http://127.0.0.1:8765/authenticate", "username=dwarf&password=foobar"
puts r.body
