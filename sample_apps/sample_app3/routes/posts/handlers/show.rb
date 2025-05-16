# frozen_string_literal: true

class PostsShowHandler < MK::Handler
  route do |r|
    if model.nil?
      r.response.status = 404
      { error: "Post not found" }
    else
      if model.is_a?(Hash)
        {
          post: model[:post].to_hash,
          comments: model[:comments].map(&:to_hash)
        }
      else
        model.to_hash
      end
    end
  end
end