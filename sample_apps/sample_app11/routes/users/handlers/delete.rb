# frozen_string_literal: true

class UsersDeleteHandler < MK::Handler
  handler do |r|
    success do
      {
        user_id: model[:id],
        message: "User deleted successfully"
      }
    end
  end
end