# frozen_string_literal: true

class TodosCreateHandler < MK::Handler
  handler do |r|
    success do |r|
      r.response.status = 201
      {
        message: "Todo created",
        todo: model.to_hash,
        custom_field: "Custom value for create"
      }
    end

    error do |r|
      r.response.status = 422
      {
        error: "Validation failed",
        details: model.errors
      }
    end
  end
end
