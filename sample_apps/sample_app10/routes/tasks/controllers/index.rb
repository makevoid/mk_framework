# frozen_string_literal: true

class TasksIndexController < MK::Controller
  route do |r|
    tasks = Task.dataset
    
    # Filter by project if provided
    if r.params['project_id']
      tasks = tasks.where(project_id: r.params['project_id'])
    end
    
    # Filter by assigned user if provided
    if r.params['assigned_to_id']
      tasks = tasks.where(assigned_to_id: r.params['assigned_to_id'])
    end
    
    # Filter by status if provided
    if r.params['status']
      tasks = tasks.where(status: r.params['status'])
    end
    
    # Filter by priority if provided
    if r.params['priority']
      tasks = tasks.where(priority: r.params['priority'])
    end
    
    tasks.all
  end
end