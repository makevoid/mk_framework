# frozen_string_literal: true

module SampleApp7
  class CommentsCreateHandler < MK::Handler
    handler do |r|
      r.response.status = 201
      {message: 'Comment created', comment: model.slice(*Comment.public_attributes_list)}
    end
  end
end
