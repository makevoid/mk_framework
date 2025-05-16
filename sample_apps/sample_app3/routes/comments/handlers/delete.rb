# frozen_string_literal: true

class CommentsDeleteHandler < MK::Handler
  route do |r|
    {
      message: "Comment deleted successfully",
      comment: model
    }
  end
end