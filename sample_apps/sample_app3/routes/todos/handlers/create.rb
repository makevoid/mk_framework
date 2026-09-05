# frozen_string_literal: true

module SampleApp3
  class TodosCreateHandler < MK::Handler
    handler do |r|
      r.response.status = 201
      {message: 'Todo created', todo: model.slice(*Todo.public_attributes_list), custom_field: 'Custom value for create'}
    end
  end
end
