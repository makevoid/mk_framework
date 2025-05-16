# frozen_string_literal: true

class CardsCreateHandler < MK::Handler
  def call
    card = controller_result
    
    unless card.valid?
      response.status = 422
      return {
        error: "Validation failed",
        details: card.errors
      }.to_json
    end
    
    card.save
    
    response.status = 201
    {
      message: "Card created",
      card: card.values
    }.to_json
  end
end