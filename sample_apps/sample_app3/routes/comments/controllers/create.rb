# frozen_string_literal: true

class CommentsCreateController < MK::Controller
  route do |r|
    post_id = r.params.fetch('post_id')
    post = Post[post_id]
    
    r.halt(404, { error: "Post not found" }.to_json) unless post
    
    comment = Comment.new(
      post_id: post_id,
      content: r.params.fetch('content'),
      author: r.params['author']
    )
    
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