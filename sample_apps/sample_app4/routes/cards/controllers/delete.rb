# frozen_string_literal: true

class CardsDeleteController < MK::Controller
  route do |r|
    id = r.params.fetch('id')
    card = Card[id]
    
    r.halt(404, { error: "Card not found" }.to_json) unless card
    
    result = card.dup
    card.delete
    result
  end
end