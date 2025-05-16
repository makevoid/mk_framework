# frozen_string_literal: true

class CommentsDeleteController < MK::Controller
  route do |r|
    comment = Comment[r.params.fetch('id')]
    
    unless comment
      r.halt(404, {}.to_json)
    end
    
    # Store the comment data before deleting
    comment_data = comment.to_hash
    
    # Delete the comment
    comment.delete
    
    # Return the deleted comment data
    comment_data
  end
end