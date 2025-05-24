# frozen_string_literal: true

class UsersShowHandler < MK::Handler
  handler do |r|
    model.to_hash
  end
end