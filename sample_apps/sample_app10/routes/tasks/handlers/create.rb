# frozen_string_literal: true

class TasksCreateHandler < MK::Handler
  handler do |r|
    success do |r|
      r.response.status = 201
      {
        message: "Task created successfully",
        task: model.to_hash(include_associations: true)
      }
    end
    
    error do |r|
      r.response.status = 422
      {
        error: "Failed to create task",
        details: model.errors
      }
    end
  end
end