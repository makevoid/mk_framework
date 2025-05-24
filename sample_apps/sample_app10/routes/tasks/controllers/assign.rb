# frozen_string_literal: true

class TasksAssignController < MK::Controller
  route do |r|
    task = Task[r.params.fetch('id')]
    r.halt(404, { error: "Task not found" }) if task.nil?
    
    user = User[r.params['user_id']]
    r.halt(404, { error: "User not found" }) if user.nil? && r.params['user_id']
    
    task.assigned_to_id = r.params['user_id']
    
    if task.valid?
      task.save
    end
    
    task
  end
end