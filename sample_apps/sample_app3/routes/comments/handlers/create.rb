# frozen_string_literal: true

class CommentsCreateHandler < MK::Handler
  route do |r|
    r.response.status = 201
    {
      message: "Comment created",
      comment: model.to_hash
    }
  end
end