# frozen_string_literal: true

class TodosCreateHandler < MK::Handler
  route do |r|
    # Process the result from the controller
    if model.save
      # Return success response with the created todo
      r.response.status = 201
      model.to_hash
    else
      # Return validation error response
      r.response.status = 422
      { 
        error: "Validation failed", 
        details: model.errors 
      }
    end
  end
end