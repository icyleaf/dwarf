require "../src/dwarf" # Change to "dwarf" in production
require "../src/dwarf/services/common" # Change to "dwarf/services/common" in production
require "http/server"
require "http/client"

# 1. Create a strategy and register it!
Dwarf::Strategies.register("password") do
  def valid?
    params["username"]? && params["password"]?
  end

  def authenticate!
    if params["username"] == "dwarf" && params["password"] == "foobar"
      user = JSON.parse({ "name" => params["username"] }.to_json)
      success!(user)
    elsif params["username"] == "icyleaf"
      custom!("Your account had been locked.")
    else
      redirect!("https://sdfsfd.sdfsdf.com/signup", "Not found email, now redirect to sign up page.", "text/html")
    end
  end
end

# 2. Configure it
dwarf_manager = Dwarf::Manager.new do |config|
  config.default_strategies(strategies: ["password"])
end

# 3. Append handler into http server
server = HTTP::Server.new("127.0.0.1", 8765, [dwarf_manager.handler]) do |context|
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

def request(url, body)
  pp url
  r = HTTP::Client.post_form url, body
  pp r.headers
  pp r.status_code
  pp r.body
end

sleep 1

request "http://127.0.0.1:8765/authenticate?language=zh-ch", "username=dwarf&password=nopass"
request "http://127.0.0.1:8765/authenticate?language=zh-ch", "username=icyleaf&password=foobar"
