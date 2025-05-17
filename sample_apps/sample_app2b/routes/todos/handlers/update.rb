# frozen_string_literal: true

class TodosUpdateHandler < MK::Handler
  route do |r|
    success do |r|
      {
        message: "Todo updated",
        todo: model.to_hash,
      } 
    end

    error do |r|
      r.response.status = 400
      {
        error: "Validation failed!",
        details: model.errors
      }
    end
  end
end
