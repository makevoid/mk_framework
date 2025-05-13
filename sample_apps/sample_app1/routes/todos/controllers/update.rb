# frozen_string_literal: true

class TodosUpdateController < MK::Controller
  route do |r|
    # Get the todo by ID
    todo = Todo[r.params.fetch('id')]
    
    # Return nil if todo not found
    return nil if todo.nil?
    
    # Update the todo with the request parameters
    params = r.params
    
    # Update only the fields that are provided
    todo.title = params['title'] if params.key?('title')
    todo.description = params['description'] if params.key?('description')
    todo.completed = params['completed'] if params.key?('completed')
    
    # Return the updated todo
    todo
  end
end