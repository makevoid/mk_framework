# frozen_string_literal: true

module SampleApp1
  class TodosCreateHandler < MK::Handler
    handler do |r|
      r.response.status = 201
      {message: 'Todo created', todo: model.slice(*Todo.public_attributes_list)}
    end
  end
end
