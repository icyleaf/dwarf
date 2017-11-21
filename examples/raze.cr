require "dwarf"
require "dwarf/services/http_server"
require "http/client"
require "raze"

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

# 2. Configure it
class Authenticator < Raze::Handler
  def initialize
    @manager = Dwarf::Manager.new do |config|
      config.register_strategy("password", PasswordStrategy.new)
      config.default_strategies(strategies: ["password"])
    end
  end

  def call(ctx, done)
    ctx.dwarf = Dwarf::Proxy.new(ctx, @manager) unless ctx.dwarf?
    ctx.dwarf.authenticate!

    done.call
  end
end

post "/authenticate", Authenticator.new do |ctx|
  if user = ctx.dwarf.user
    "Logged in, hello #{user["name"]}!"
  else
    "Auth request!"
  end
end

spawn do
  Raze.config.port = 8765
  Raze.run
end

sleep 1

r = HTTP::Client.post_form "http://127.0.0.1:8765/authenticate", "username=dwarf&password=foobar"
puts r.body
