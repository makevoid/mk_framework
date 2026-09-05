# frozen_string_literal: true

module SampleApp1
  class TodosShowHandler < MK::Handler
    handler do |r|
      model.public_attributes
    end
  end
end
