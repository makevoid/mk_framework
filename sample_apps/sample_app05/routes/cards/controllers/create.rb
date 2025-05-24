# frozen_string_literal: true

class CardsCreateController < MK::Controller
  route do |r|
    card_params = {}

    # Optional fields - title is required by model validation
    card_params[:title] = r.params['title'] if r.params['title']
    card_params[:description] = r.params['description'] if r.params['description']
    card_params[:status] = r.params['status'] if r.params['status']

    card = Card.new(card_params)

    unless card.valid?
      r.halt(422, {
        error: "Validation failed",
        details: card.errors
      }.to_json)
    end

    card
  end
end
