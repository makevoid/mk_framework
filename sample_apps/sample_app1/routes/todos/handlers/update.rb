# frozen_string_literal: true

module SampleApp1
  class TodosUpdateHandler < MK::Handler
    handler do |r|
      {message: 'Todo updated', todo: model.slice(*Todo.public_attributes_list)}
    end
  end
end
