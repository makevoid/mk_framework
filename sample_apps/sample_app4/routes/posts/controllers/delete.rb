# frozen_string_literal: true

module SampleApp4
  class PostsDeleteController < Controller
    route do |r|
      post = Post[r.path_params.fetch(:id)]
      raise MK::NotFound, 'Post not found' unless post

      post
    end
  end
end
