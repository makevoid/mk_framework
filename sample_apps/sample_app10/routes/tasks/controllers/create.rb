# frozen_string_literal: true

class TasksCreateController < MK::Controller
  route do |r|
    # Verify project exists
    project = Project[r.params['project_id']]
    r.halt(404, { error: "Project not found" }) if project.nil?
    
    task = Task.new(
      title: r.params['title'],
      description: r.params['description'],
      status: r.params['status'] || 'todo',
      priority: r.params['priority'] || 'medium',
      project_id: r.params['project_id'],
      assigned_to_id: r.params['assigned_to_id'],
      created_by_id: r.params['created_by_id'],
      due_date: r.params['due_date'],
      estimated_hours: r.params['estimated_hours']
    )
    
    if task.valid?
      task.save
    end
    
    task
  end
end