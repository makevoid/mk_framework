# frozen_string_literal: true

module SampleApp3
  class TodosIndexHandler < MK::Handler
    handler do |r|
      {todos: model.map { |attributes| attributes.slice(*Todo.public_attributes_list) }, custom_field: 'Custom value for index'}
    end
  end
end
