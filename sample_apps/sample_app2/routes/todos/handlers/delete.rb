# frozen_string_literal: true

class TodosDeleteHandler < MK::Handler
  route do |r|
    todo_info = model.to_hash
    
    if model.delete
      {
        message: "Todo deleted successfully",
        todo: todo_info
      }
    else
      r.response.status = 500
      {
        error: "Failed to delete todo"
      }
    end
  end
end