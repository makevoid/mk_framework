# frozen_string_literal: true

class PostsCreateController < MK::Controller
  route do |r|
    Post.new(
      title: r.params['title'],
      description: r.params['description']
    )
  end
end