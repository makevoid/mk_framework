# frozen_string_literal: true

module SampleApp5
  class CommentsIndexHandler < MK::Handler
    handler do |r|
      model.map { |attributes| attributes.slice(*Comment.public_attributes_list) }
    end
  end
end
