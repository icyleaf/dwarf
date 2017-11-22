require "dwarf"
require "dwarf/services/kemal"
require "http/client"
require "kemal"

# 1. Create a strategy
class PasswordStrategy < Dwarf::Strategies::Base
  def valid?
    params["username"]? && params["password"]?
  end

  def authenticate!
    if params["username"] == "dwarf" && params["password"] == "foobar"
      user = JSON.parse({ "name" => params["username"] }.to_json)
      success!(user)
    else
      fail!
    end
  end
end

# 2. Configure and register it!
dwarf_manager = Dwarf::Manager.new do |config|
  config.register_strategy("password", PasswordStrategy.new)
  config.default_strategies(strategies: ["password"])
end

post "/authenticate" do |env|
  env.dwarf.authenticate!
  if user = env.dwarf.user
    "Logged in, hello #{user["name"]}!"
  else
    "Auth request!"
  end
end

spawn do
  # 3. Append handler into http server
  Kemal.config.add_handler dwarf_manager.handler
  Kemal.run(8765)
end

sleep 1

r = HTTP::Client.post_form "http://127.0.0.1:8765/authenticate", "username=dwarf&password=foobar"
puts r.body
