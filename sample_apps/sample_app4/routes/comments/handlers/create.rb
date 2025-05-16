# frozen_string_literal: true

class CommentsCreateHandler < MK::Handler
  route do |r|
    success do |r|
      r.response.status = 201
      {
        message: "Comment created",
        comment: model.to_hash,
      }
    end

    error do |r|
      r.response.status = 422
      {
        error: "Validation failed",
        details: model.errors
      }
    end
  end

end
