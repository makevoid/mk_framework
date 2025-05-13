# frozen_string_literal: true

class TodosDeleteHandler < MK::Handler
  route do |r|
    # Handle case where todo was not found
    if model.nil?
      r.response.status = 404
      return { error: "Todo not found" }
    end
    
    # Store todo info before deletion for returning to client
    todo_info = model.to_hash
    
    # Delete the todo
    if model.delete
      # Return success message with the deleted todo info
      {
        message: "Todo deleted successfully",
        todo: todo_info
      }
    else
      # Return error if deletion fails
      r.response.status = 500
      {
        error: "Failed to delete todo"
      }
    end
  end
end