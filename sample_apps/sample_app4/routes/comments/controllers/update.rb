# frozen_string_literal: true

module SampleApp4
  class CommentsUpdateController < Controller
    route do |r|
      comments = Comment.where(id: r.path_params.fetch(:id))
      if (post_id = r.path_params[:post_id])
        post = Post[post_id]
        raise MK::NotFound, 'Post not found' unless post

        comments = post.comments_dataset.where(id: r.path_params.fetch(:id))
      end
      comment = comments.first
      raise MK::NotFound, 'Comment not found' unless comment

      comment.set(r.input.permit(content: [String, NilClass], author: [String, NilClass]))
      comment
    end
  end
end
