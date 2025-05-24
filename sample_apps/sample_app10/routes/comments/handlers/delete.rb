# frozen_string_literal: true

class CommentsDeleteHandler < MK::Handler
  handler do |r|
    {
      message: "Comment deleted successfully",
      comment: model.to_hash
    }
  end
end