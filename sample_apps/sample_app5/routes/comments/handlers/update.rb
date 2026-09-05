# frozen_string_literal: true

module SampleApp5
  class CommentsUpdateHandler < MK::Handler
    handler do |r|
      {message: 'Comment updated', comment: model.slice(*Comment.public_attributes_list)}
    end
  end
end
