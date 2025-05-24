# frozen_string_literal: true

class TasksAssignHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: model.assigned_to ? "Task assigned to #{model.assigned_to.name}" : "Task unassigned",
        task: model.to_hash(include_associations: true)
      }
    end
    
    error do |r|
      r.response.status = 422
      {
        error: "Failed to assign task",
        details: model.errors
      }
    end
  end
end