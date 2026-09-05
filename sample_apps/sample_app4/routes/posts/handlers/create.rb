# frozen_string_literal: true

module SampleApp4
  class PostsCreateHandler < MK::Handler
    handler do |r|
      r.response.status = 201
      {message: 'Post created', post: model.public_attributes}
    end
  end
end
