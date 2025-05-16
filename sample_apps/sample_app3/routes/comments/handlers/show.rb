# frozen_string_literal: true

class CommentsShowHandler < MK::Handler
  route do |r|
    if model.nil?
      r.response.status = 404
      { error: "Comment not found" }
    else
      model.to_hash
    end
  end
end