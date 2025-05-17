# frozen_string_literal: true

class CommentsShowHandler < MK::Handler
  handler do |r|
    if model.nil?
      r.response.status = 404
      { error: "Comment not found" }
    else
      model.to_hash
    end
  end
end
