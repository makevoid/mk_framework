# frozen_string_literal: true

class TodosCreateController < MK::Controller
  route do |r|
    Todo.new(
      title: r.params['title'],
      description: r.params['description'],
      completed: r.params['completed'] || false
    )
  end
end
