# frozen_string_literal: true

class CommentsDeleteController < MK::Controller
  route do |r|
    comment = Comment[r.params.fetch('id')]

    unless comment
      r.halt(404, { error: "Comment not found" })
    end

    comment
  end
end
