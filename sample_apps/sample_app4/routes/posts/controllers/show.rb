# frozen_string_literal: true

class PostsShowController < MK::Controller
  route do |r|
    post = Post[r.params.fetch('id')]

    r.halt 404, { error: "Post not found" } unless post

    comments = Comment.where(post_id: post.id).all

    {
      post: post,
      comments: comments
    }
  end
end
