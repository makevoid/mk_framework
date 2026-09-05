# frozen_string_literal: true

module SampleApp4
  class PostsShowHandler < MK::Handler
    handler do |r|
      {
        post: model.fetch(:post).slice(*Post.public_attributes_list),
        comments: model.fetch(:comments).map { |comment| comment.slice(*Comment.public_attributes_list) }
      }
    end
  end
end
