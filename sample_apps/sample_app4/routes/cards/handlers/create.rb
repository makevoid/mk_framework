# frozen_string_literal: true

class CardsCreateHandler < MK::Handler
  route do |r|
    card = model

    unless card.valid?
      r.halt 422, {
        error: "Validation failed",
        details: card.errors
      }
    end

    card.save

    r.response.status = 201
    {
      message: "Card created",
      card: card.values
    }
  end
end
