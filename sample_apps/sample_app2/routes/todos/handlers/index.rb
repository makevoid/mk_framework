# frozen_string_literal: true

module SampleApp2
  class TodosIndexHandler < MK::Handler
    handler do |r|
      model.map(&:public_attributes)
    end
  end
end
