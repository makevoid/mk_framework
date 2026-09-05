# frozen_string_literal: true

module SampleApp4
  class CommentsDeleteHandler < MK::Handler
    handler do |r|
      {message: 'Comment deleted successfully', comment: model.public_attributes}
    end
  end
end
