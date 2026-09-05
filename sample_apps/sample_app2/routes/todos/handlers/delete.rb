# frozen_string_literal: true

module SampleApp2
  class TodosDeleteHandler < MK::Handler
    handler do |r|
      {message: 'Todo deleted successfully', todo: model.public_attributes}
    end
  end
end
