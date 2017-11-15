module Dwarf
  class SessionSerializer
    getter context

    def initialize(@context : HTTP::Server::Context)
    end

    def serialize(user)
      user
    end

    def deserialize(key)
      key
    end

    def store(user, scope)
      return unless user

      session[key_for(scope)] = serialize(user)
    end

    def fetch(scope)
      key = session[key_for(scope)]
      return nil unless key

      user = deserialize(key)
      delete(scope) unless user
      user
    end

    def stored?(scope)
      !!session[key_for(scope)]
    end

    def delete(scope)
      session.delete(key_for(scope))
    end

    def key_for(scope : String)
      "dwarf.user.#{scope}.key"
    end

    def session
      env.dwarf_session
    end
  end
end
