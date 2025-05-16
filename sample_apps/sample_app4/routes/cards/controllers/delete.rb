# frozen_string_literal: true

class CardsDeleteController < MK::Controller
  route do |r|
    id = r.params['id']
    card = Card[id]
    
    r.halt(404, {}.to_json) unless card
    
    card_copy = card.dup
    card.destroy
    
    card_copy
  end
end