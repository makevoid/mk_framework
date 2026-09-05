# frozen_string_literal: true

module SampleApp2
  class TodosDeleteHandler < MK::Handler
    handler do |r|
      {message: 'Todo deleted successfully', todo: model.slice(*Todo.public_attributes_list)}
    end
  end
end
