# frozen_string_literal: true

class PostsShowController < MK::Controller
  route do |r|
    post = Post[r.params.fetch('id')]
    
    if post
      # Load comments for the post
      comments = Comment.where(post_id: post.id).all
      
      # Create a hash with post and comments
      {
        post: post,
        comments: comments
      }
    else
      nil
    end
  end
end