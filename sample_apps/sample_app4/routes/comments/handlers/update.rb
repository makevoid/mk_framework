# frozen_string_literal: true

module SampleApp4
  class CommentsUpdateHandler < MK::Handler
    handler do |r|
      {message: 'Comment updated', comment: model.public_attributes}
    end
  end
end
