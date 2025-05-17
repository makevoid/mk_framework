# frozen_string_literal: true

class PostsUpdateHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Post updated",
        post: model.to_hash,
      }
    end

    error do |r|
      r.response.status = 400
      {
        error: "Validation failed!",
        details: model.errors
      }
    end
  end
end
