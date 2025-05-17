# frozen_string_literal: true

class TodosIndexHandler < MK::Handler
  handler do |r|
    # TODO: change model to resource in index route
    {
      todos: model.map(&:to_hash),
      custom_field: "Custom value for index"
    }
  end
end
