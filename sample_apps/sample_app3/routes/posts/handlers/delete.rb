# frozen_string_literal: true

class PostsDeleteHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Post deleted successfully",
        post: model.to_hash
      }
    end

    error do |r|
      r.response.status = 500
      {
        error: "Failed to delete post"
      }
    end
  end
end
