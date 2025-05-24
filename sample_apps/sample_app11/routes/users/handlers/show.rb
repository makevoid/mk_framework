# frozen_string_literal: true

class UsersShowHandler < MK::Handler
  handler do |r|
    {
      user: model
    }
  end
end