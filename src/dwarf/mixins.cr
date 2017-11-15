module Dwarf
  module Mixins
    def session
      context.session
    end

    def request
      context.request
    end

    def reset_session!
      session.clear
    end
  end
end
