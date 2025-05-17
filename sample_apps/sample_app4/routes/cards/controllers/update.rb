# frozen_string_literal: true

class CardsUpdateController < MK::Controller
  route do |r|
    id = r.params.fetch('id')
    card = Card[id]

    r.halt(404, { error: "Card not found" }.to_json) unless card

    card.title = r.params['title'] if r.params['title']
    card.description = r.params['description'] if r.params['description']
    card.status = r.params['status'] if r.params['status']

    unless card.valid?
      r.halt(400, {
        error: "Validation failed!",
        details: card.errors
      }.to_json)
    end

    card
  end
end
