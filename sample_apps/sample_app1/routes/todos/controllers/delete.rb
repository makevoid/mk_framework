# frozen_string_literal: true

class TodosDeleteController < MK::Controller
  route do |r|
    todo = Todo[r.params.fetch('id')]
    
    r.halt 404 if todo.nil?
    
    todo
  end
end