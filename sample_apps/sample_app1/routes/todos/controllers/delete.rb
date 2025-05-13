# frozen_string_literal: true

class TodosDeleteController < MK::Controller
  route do |r|
    # Get the todo by ID
    todo = Todo[r.params.fetch('id')]
    
    # Return nil if todo not found
    return nil if todo.nil?
    
    # Mark for deletion and return the todo
    todo
  end
end