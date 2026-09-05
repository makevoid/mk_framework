# frozen_string_literal: true

module SampleApp4
  class PostsIndexHandler < MK::Handler
    handler do |r|
      model.map(&:public_attributes)
    end
  end
end
