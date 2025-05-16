# frozen_string_literal: true

class CommentsUpdateController < MK::Controller
  route do |r|
    comment = Comment[r.params.fetch('id')]

    unless comment
      r.halt(404, { error: "Comment not found" }.to_json)
    end

    if r.params['content']
      comment.content = r.params['content']
    end

    if r.params['author']
      comment.author = r.params['author']
    end

    unless comment.valid?
      r.halt(400, {
        error: "Validation failed!",
        details: comment.errors
      }.to_json)
    end

    comment.save
    comment
  end
end
