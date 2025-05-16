# frozen_string_literal: true

class TodosIndexHandler < MK::Handler
  route do |r|
    # TODO: change model to resource in index route
    model.map(&:to_hash)
  end
end
