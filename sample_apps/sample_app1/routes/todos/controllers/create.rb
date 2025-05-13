# frozen_string_literal: true

class TodosCreateController < MK::Controller
  route do |r|
    # Parse JSON request body and create a new Todo model
    params = r.params
    
    # Create a new Todo with the provided parameters
    Todo.new(
      title: params['title'],
      description: params['description'],
      completed: params['completed'] || false
    )
  end
end