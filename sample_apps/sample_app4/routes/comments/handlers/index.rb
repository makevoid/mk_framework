# frozen_string_literal: true

class CommentsIndexHandler < MK::Handler
  route do |r|
    model.map(&:to_hash)
  end
end