# frozen_string_literal: true

class PostsIndexHandler < MK::Handler
  route do |r|
    model.map(&:to_hash)
  end
end