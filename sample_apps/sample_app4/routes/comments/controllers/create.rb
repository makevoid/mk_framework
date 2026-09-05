# frozen_string_literal: true

module SampleApp4
  class CommentsCreateController < Controller
    route do |r|
      post = Post[r.path_params.fetch(:post_id)]
      raise MK::NotFound, 'Post not found' unless post

      attributes = r.input.permit(content: [String, NilClass], author: [String, NilClass])
      Comment.new(attributes.merge(post_id: post.id))
    end
  end
end
