# frozen_string_literal: true

module SampleApp4
  class CommentsShowHandler < MK::Handler
    handler do |r|
      model.slice(*Comment.public_attributes_list)
    end
  end
end
