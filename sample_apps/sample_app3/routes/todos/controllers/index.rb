# frozen_string_literal: true

class TodosIndexController < MK::Controller
  route do |r|
    Todo.all
  end
end
