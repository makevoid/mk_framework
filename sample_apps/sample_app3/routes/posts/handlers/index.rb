# frozen_string_literal: true

class PostsIndexHandler < MK::Handler
  handler do |r|
    model.map(&:to_hash)
  end
end
