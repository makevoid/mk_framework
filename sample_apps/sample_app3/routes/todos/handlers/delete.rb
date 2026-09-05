# frozen_string_literal: true

module SampleApp3
  class TodosDeleteHandler < MK::Handler
    handler do |r|
      {message: 'Todo deleted successfully', todo: model.slice(*Todo.public_attributes_list), custom_field: 'Custom value for delete'}
    end
  end
end
