# frozen_string_literal: true

module SampleApp4
  class PostsShowController < Controller
    route do |r|
      post = Post[r.path_params.fetch(:id)]
      raise MK::NotFound, 'Post not found' unless post

      page = r.page
      comments = post.comments_dataset.order(:id).limit(page[:limit], page[:offset]).all
      {post: post, comments: comments}
    end
  end
end
