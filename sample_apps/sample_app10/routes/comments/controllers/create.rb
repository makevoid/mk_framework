# frozen_string_literal: true

class CommentsCreateController < MK::Controller
  route do |r|
    # Verify task exists
    task = Task[r.params['task_id']]
    r.halt(404, { error: "Task not found" }) if task.nil?
    
    comment = Comment.new(
      content: r.params['content'],
      task_id: r.params['task_id'],
      user_id: r.params['user_id']
    )
    
    comment
  end
end