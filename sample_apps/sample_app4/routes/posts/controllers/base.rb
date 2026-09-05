# frozen_string_literal: true

module SampleApp4
  class PostsController < Controller
    def dataset(_r) = Post.dataset

    def find(r)
      dataset(r).where(id: r.path_params.fetch(:id)).first or raise MK::NotFound, 'Post not found'
    end
  end
end
