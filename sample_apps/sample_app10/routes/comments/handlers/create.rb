# frozen_string_literal: true

class CommentsCreateHandler < MK::Handler
  handler do |r|
    success do |r|
      r.response.status = 201
      {
        message: "Comment created successfully",
        comment: model.to_hash
      }
    end
    
    error do |r|
      r.response.status = 422
      {
        error: "Failed to create comment",
        details: model.errors
      }
    end
  end
end