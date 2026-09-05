# frozen_string_literal: true

module SampleApp4
  class CommentsShowHandler < MK::Handler
    handler do |r|
      model.public_attributes
    end
  end
end
