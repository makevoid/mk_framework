# frozen_string_literal: true

class UsersCreateHandler < MK::Handler
  handler do |r|
    success do |r|
      r.response.status = 201
      {
        message: "User created successfully",
        user: model.to_hash
      }
    end
    
    error do |r|
      r.response.status = 422
      {
        error: "Failed to create user",
        details: model.errors
      }
    end
  end
end