# frozen_string_literal: true

class PostsUpdateController < MK::Controller
  route do |r|
    post = Post[r.params.fetch('id')]

    r.halt(404, { message: "post not found" }) if post.nil?

    params = r.params

    post.title = params['title'] if params.key?('title')
    post.description = params['description'] if params.key?('description')

    post
  end
end