# frozen_string_literal: true

class CommentsIndexController < MK::Controller
  route do |r|
    post_id = r.params.fetch('post_id')
    post = Post[post_id]
    
    r.halt(404, { error: "Post not found" }.to_json) unless post
    
    Comment.where(post_id: post_id).all
  end
end