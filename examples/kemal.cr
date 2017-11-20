require "./password_strategy"
require "../src/dwarf/services/kemal" # Change to "dwarf/services/kemal" in production
require "http/client"
require "kemal"

dwarf_manager = Dwarf::Manager.new do |config|
  config.register_strategy("password", PasswordStrategy.new)
  config.default_strategies(strategies: ["password"])
end

post "/authenticate" do |env|
  env.dwarf.authenticate!
  if user = env.dwarf.user
    "Logged in, hello #{user["name"]}"
  else
    "Auth request!"
  end
end

spawn do
  Kemal.config.add_handler dwarf_manager.handler
  Kemal.run(8765)
end

sleep 1

r = HTTP::Client.post_form "http://127.0.0.1:8765/authenticate", "username=dwarf&password=foobar"
puts r.body
