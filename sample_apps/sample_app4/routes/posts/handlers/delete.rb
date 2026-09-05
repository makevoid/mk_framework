# frozen_string_literal: true

module SampleApp4
  class PostsDeleteHandler < MK::Handler
    handler do |r|
      {message: 'Post deleted successfully', post: model.public_attributes}
    end
  end
end
