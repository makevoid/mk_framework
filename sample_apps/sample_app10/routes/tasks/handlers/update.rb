# frozen_string_literal: true

class TasksUpdateHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Task updated successfully",
        task: model.to_hash(include_associations: true)
      }
    end
    
    error do |r|
      r.response.status = 422
      {
        error: "Failed to update task",
        details: model.errors
      }
    end
  end
end