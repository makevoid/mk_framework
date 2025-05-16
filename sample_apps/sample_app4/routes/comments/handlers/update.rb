# frozen_string_literal: true

class CommentsUpdateHandler < MK::Handler
  route do |r|
    {
      message: "Comment updated",
      comment: model.to_hash
    }
  end
end