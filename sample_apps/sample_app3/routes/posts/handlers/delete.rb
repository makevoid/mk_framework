# frozen_string_literal: true

class PostsDeleteHandler < MK::Handler
  route do |r|
    post_info = model.to_hash
    
    if model.delete
      {
        message: "Post deleted successfully",
        post: post_info
      }
    else
      r.response.status = 500
      {
        error: "Failed to delete post"
      }
    end
  end
end