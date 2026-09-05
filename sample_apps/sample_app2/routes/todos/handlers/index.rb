# frozen_string_literal: true

module SampleApp2
  class TodosIndexHandler < MK::Handler
    handler do |r|
      model.map { |attributes| attributes.slice(*Todo.public_attributes_list) }
    end
  end
end
