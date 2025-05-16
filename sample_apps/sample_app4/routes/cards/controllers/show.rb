# frozen_string_literal: true

class CardsShowController < MK::Controller
  route do |r|
    id = r.params['id']
    card = Card[id]
    
    r.halt(404, { error: "Card not found" }.to_json) unless card
    
    {
      card: card,
      comments: Comment.where(card_id: id).all
    }
  end
end