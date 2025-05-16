# frozen_string_literal: true

class PostsShowHandler < MK::Handler
  route do |r|
    if model.nil?
      r.response.status = 404
      { error: "Post not found" }
    else
      model.to_hash
    end
  end
end