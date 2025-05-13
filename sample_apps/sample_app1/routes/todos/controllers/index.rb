# frozen_string_literal: true

class TodosIndexController < MK::Controller
  route do |r|
    # Get all todos from the database
    Todo.all
  end
end