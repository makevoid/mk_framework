# frozen_string_literal: true

require_relative 'base'

module SampleApp3
  class TodosCreateController < TodosController
    route do |r|
      persist(Todo.new(r.input.permit(title: [String, NilClass], description: [String, NilClass], completed: :boolean)))
    end
  end
end
