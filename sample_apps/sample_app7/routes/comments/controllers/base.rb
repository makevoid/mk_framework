# frozen_string_literal: true

module SampleApp7
  class CommentsController < Controller
    def dataset(r)
      if (parent_id = r.path_params[:card_id])
        parent = Card[parent_id] or raise MK::NotFound, 'Card not found'
        parent.comments_dataset
      else
        Comment.dataset
      end
    end

    def find(r)
      dataset(r).where(id: r.path_params.fetch(:id)).first or raise MK::NotFound, 'Comment not found'
    end
  end
end
