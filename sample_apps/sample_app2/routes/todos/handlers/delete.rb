# frozen_string_literal: true

class TodosDeleteHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Todo deleted successfully",
        todo: model.to_hash,
        custom_field: "Custom value for delete"
      }
    end

    error do |r|
      r.response.status = 500
      {
        error: "Failed to delete todo"
      }
    end
  end
end
