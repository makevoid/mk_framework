# frozen_string_literal: true

module SampleApp4
  class CommentsIndexController < Controller
    route do |r|
      post = Post[r.path_params.fetch(:post_id)]
      raise MK::NotFound, 'Post not found' unless post

      page = r.page
      post.comments_dataset.order(:id).limit(page[:limit], page[:offset]).all
    end
  end
end
