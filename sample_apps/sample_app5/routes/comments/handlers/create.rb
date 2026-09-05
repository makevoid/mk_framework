# frozen_string_literal: true

module SampleApp5
  class CommentsCreateHandler < MK::Handler
    handler do |r|
      r.response.status = 201
      {message: 'Comment created', comment: model.public_attributes}
    end
  end
end
