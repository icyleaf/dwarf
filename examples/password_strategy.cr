require "../src/dwarf" # Change to "dwarf" in production

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
