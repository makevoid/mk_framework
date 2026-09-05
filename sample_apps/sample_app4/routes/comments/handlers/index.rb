# frozen_string_literal: true

module SampleApp4
  class CommentsIndexHandler < MK::Handler
    handler do |r|
      model.map { |comment| comment.slice(*Comment.public_attributes_list) }
    end
  end
end
