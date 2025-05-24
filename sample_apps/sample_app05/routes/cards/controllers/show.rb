# frozen_string_literal: true

class CardsShowController < MK::Controller
  route do |r|
    id = r.params.fetch('id')
    card = Card[id]

    r.halt(404, { error: "Card not found" }.to_json) unless card

    comments = Comment.where(card_id: id).all

    {
      card: card,
      comments: comments
    }
  end
end
