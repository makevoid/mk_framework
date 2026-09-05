# frozen_string_literal: true

module SampleApp1
  class TodosUpdateHandler < MK::Handler
    handler do |r|
      {message: 'Todo updated', todo: model.public_attributes}
    end
  end
end
