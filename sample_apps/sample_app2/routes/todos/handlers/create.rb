# frozen_string_literal: true

module SampleApp2
  class TodosCreateHandler < MK::Handler
    handler do |r|
      r.response.status = 201
      {message: 'Todo created', todo: model.public_attributes}
    end
  end
end
