# frozen_string_literal: true

module SampleApp4
  class PostsDeleteHandler < MK::Handler
    handler do |r|
      {message: 'Post deleted successfully', post: model.slice(*Post.public_attributes_list)}
    end
  end
end
