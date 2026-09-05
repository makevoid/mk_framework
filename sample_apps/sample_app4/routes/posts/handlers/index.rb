# frozen_string_literal: true

module SampleApp4
  class PostsIndexHandler < MK::Handler
    handler do |r|
      model.map do |post|
        attributes = post.slice(*Post.public_attributes_list)
        if post.key?(:comments)
          attributes[:comments] = post.fetch(:comments).map { |comment| comment.slice(*Comment.public_attributes_list) }
        end
        attributes
      end
    end
  end
end
