# frozen_string_literal: true

class PostsDeleteController < MK::Controller
  route do |r|
    post = Post[r.params.fetch('id')]

    r.halt(404, { error: "Post not found" }) if post.nil?

    post
  end
end
