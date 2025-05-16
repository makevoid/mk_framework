# frozen_string_literal: true

class CommentsCreateController < MK::Controller
  route do |r|
    card_id = r.params.fetch('card_id')
    card = Card[card_id]
    
    r.halt(404, { error: "Card not found" }.to_json) unless card
    
    comment_params = { card_id: card_id }
    
    # Optional fields - content is required by model validation
    comment_params[:content] = r.params['content'] if r.params['content']
    comment_params[:author] = r.params['author'] if r.params['author']
    
    comment = Comment.new(comment_params)
    
    unless comment.valid?
      r.halt(422, { 
        error: "Validation failed",
        details: comment.errors
      }.to_json)
    end
    
    comment.save
    comment
  end
end