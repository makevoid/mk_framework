# frozen_string_literal: true

module SampleApp4
  class PostsCreateHandler < MK::Handler
    handler do |r|
      r.response.status = 201
      {message: 'Post created', post: model.slice(*Post.public_attributes_list)}
    end
  end
end
