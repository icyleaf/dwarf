# 1. Open `config/route.cr` and create a strategy and register it!

#### `config/route.cr`
require "dwarf"
require "dwarf/services/amber"
Dwarf::Strategies.register("password") do
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

dwarf_manager = Dwarf::Manager.new do |config|
  config.default_strategies(strategies: ["password"])
end

Amber::Server.configure do |app|
  pipeline :web do
    # Plug is the method to use connect a pipe (middleware)
    # A plug accepts an instance of HTTP::Handler
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Logger.new
    plug Amber::Pipe::Session.new
    plug Amber::Pipe::Flash.new
    # plug Amber::Pipe::CSRF.new
    plug dwarf_manager.handler
  end

  routes :web do
    get "/", HomeController, :index
    post "/authenticate", AuthenticateController, :index
  end
end
####

# 2. Create `src/controllers/authenticate_controller.cr` and add authenticate code
#### `src/controllers/authenticate_controller.cr`
class AuthenticateController < ApplicationController
  def index
    context.dwarf.authenticate!

    if user = context.dwarf.user
      "Logged in, hello #{user["name"]}!"
    else
      "Auth request!"
    end
  end
end
####
