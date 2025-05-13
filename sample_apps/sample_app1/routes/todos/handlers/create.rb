# frozen_string_literal: true

class TodosCreateHandler < MK::Handler
  route do |r|
    # Use success and fail blocks
    success do |r|
      # Return success response with the created todo
      r.response.status = 201
      model.to_hash
    end

    error do |r|
      # Return validation error response
      r.response.status = 422
      {
        error: "Validation failed",
        details: model.errors
      }
    end
  end
end
