# frozen_string_literal: true

module SampleApp3
  class TodosShowHandler < MK::Handler
    handler do |r|
      model.public_attributes
    end
  end
end
