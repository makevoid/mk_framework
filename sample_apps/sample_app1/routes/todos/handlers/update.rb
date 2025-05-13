# frozen_string_literal: true

class TodosUpdateHandler < MK::Handler
  route do |r|
    # Handle case where todo was not found
    if model.nil?
      r.response.status = 404
      return { error: "Todo not found" }
    end
    
    # Save the updated todo
    if model.save
      # Return the updated todo
      model.to_hash
    else
      # Return validation errors if save fails
      r.response.status = 422
      { 
        error: "Validation failed", 
        details: model.errors 
      }
    end
  end
end