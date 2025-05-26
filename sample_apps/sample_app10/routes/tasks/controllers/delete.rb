# frozen_string_literal: true

class TasksDeleteController < MK::Controller
  route do |r|
    task = Task[r.params.fetch('id')]
    r.halt(404, { error: "Task not found" }) if task.nil?
    
    task
  end
end