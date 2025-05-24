# frozen_string_literal: true

class UsersUpdateHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "User updated successfully",
        user: model.to_hash
      }
    end
    
    error do |r|
      r.response.status = 422
      {
        error: "Failed to update user",
        details: model.errors
      }
    end
  end
end