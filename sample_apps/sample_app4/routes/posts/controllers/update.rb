# frozen_string_literal: true

module SampleApp4
  class PostsUpdateController < Controller
    route do |r|
      post = Post[r.path_params.fetch(:id)]
      raise MK::NotFound, 'Post not found' unless post

      post.set(r.input.permit(title: [String, NilClass], description: [String, NilClass]))
      post
    end
  end
end
