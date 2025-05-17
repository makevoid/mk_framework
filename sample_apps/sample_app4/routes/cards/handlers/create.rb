# frozen_string_literal: true

class CardsCreateHandler < MK::Handler
  route do |r|
    success do |r|
      r.response.status = 201
      {
        message: "Card created",
        card: model.to_hash,
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