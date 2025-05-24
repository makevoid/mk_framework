# frozen_string_literal: true

class PostsShowHandler < MK::Handler
  handler do |r|
    {
      post: model.fetch(:post).to_hash,
      comments: model.fetch(:comments).map(&:to_hash)
    }
  end
end
