# frozen_string_literal: true

class UsersDeleteHandler < MK::Handler
  handler do |r|
    {
      message: "User deleted successfully",
      user: model.to_hash
    }
  end
end