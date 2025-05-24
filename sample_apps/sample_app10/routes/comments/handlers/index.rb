# frozen_string_literal: true

class CommentsIndexHandler < MK::Handler
  handler do |r|
    {
      comments: model.map(&:to_hash),
      total: model.count
    }
  end
end