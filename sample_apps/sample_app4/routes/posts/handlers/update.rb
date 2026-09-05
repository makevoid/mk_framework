# frozen_string_literal: true

module SampleApp4
  class PostsUpdateHandler < MK::Handler
    handler do |r|
      {message: 'Post updated', post: model.public_attributes}
    end
  end
end
