# frozen_string_literal: true

class CommentsDeleteController < MK::Controller
  route do |r|
    comment = Comment[r.params.fetch('id')]
    r.halt(404, { error: "Comment not found" }) if comment.nil?
    
    comment.destroy
    comment
  end
end