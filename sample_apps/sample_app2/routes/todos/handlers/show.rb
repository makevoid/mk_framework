# frozen_string_literal: true

module SampleApp2
  class TodosShowHandler < MK::Handler
    handler do |r|
      model.slice(*Todo.public_attributes_list)
    end
  end
end
