# frozen_string_literal: true

class CommentsShowHandler < MK::Handler
  handler do |r|
    model.to_hash
  end
end
