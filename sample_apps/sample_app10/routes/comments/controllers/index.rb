# frozen_string_literal: true

class CommentsIndexController < MK::Controller
  route do |r|
    comments = Comment.dataset
    
    # Filter by task if provided
    if r.params['task_id']
      comments = comments.where(task_id: r.params['task_id'])
    end
    
    # Filter by user if provided
    if r.params['user_id']
      comments = comments.where(user_id: r.params['user_id'])
    end
    
    comments.order(:created_at).all
  end
end