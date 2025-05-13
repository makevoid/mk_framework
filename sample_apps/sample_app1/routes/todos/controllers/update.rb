# frozen_string_literal: true

class TodosUpdateController < MK::Controller
  route do |r|
    todo = Todo[r.params.fetch('id')]

    return nil if todo.nil?

    params = r.params

    todo.title = params['title'] if params.key?('title')
    todo.description = params['description'] if params.key?('description')
    todo.completed = params['completed'] if params.key?('completed')

    todo
  end
end
