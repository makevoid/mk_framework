# frozen_string_literal: true

class CommentsIndexController < MK::Controller
  route do |r|
    card_id = r.params.fetch('card_id')
    card = Card[card_id]
    
    r.halt(404, { error: "Card not found" }.to_json) unless card
    
    Comment.where(card_id: card_id).all
  end
end