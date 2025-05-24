# frozen_string_literal: true

class TasksUpdateController < MK::Controller
  route do |r|
    task = Task[r.params.fetch('id')]
    r.halt(404, { error: "Task not found" }) if task.nil?
    
    update_params = {}
    update_params[:title] = r.params['title'] if r.params.key?('title')
    update_params[:description] = r.params['description'] if r.params.key?('description')
    update_params[:status] = r.params['status'] if r.params.key?('status')
    update_params[:priority] = r.params['priority'] if r.params.key?('priority')
    update_params[:assigned_to_id] = r.params['assigned_to_id'] if r.params.key?('assigned_to_id')
    update_params[:due_date] = r.params['due_date'] if r.params.key?('due_date')
    update_params[:estimated_hours] = r.params['estimated_hours'] if r.params.key?('estimated_hours')
    update_params[:actual_hours] = r.params['actual_hours'] if r.params.key?('actual_hours')
    
    task.update(update_params) unless update_params.empty?
    task
  end
end