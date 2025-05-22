# frozen_string_literal: true

class TodosIndexHandler < MK::Handler
  handler do |r|
    # TODO: change model to resource in index route
    model.map(&:to_hash)
  end
end
