# frozen_string_literal: true

class CommentsDeleteHandler < MK::Handler
  route do |r|
    success do |r|
      {
        message: "Comment deleted successfully",
        comment: model.to_hash
      }
    end

    error do |r|
      r.response.status = 500
      {
        error: "Failed to delete comment"
      }
    end
  end
end
