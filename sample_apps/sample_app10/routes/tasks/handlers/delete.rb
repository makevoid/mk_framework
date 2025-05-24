# frozen_string_literal: true

class TasksDeleteHandler < MK::Handler
  handler do |r|
    {
      message: "Task deleted successfully",
      task: model.to_hash
    }
  end
end