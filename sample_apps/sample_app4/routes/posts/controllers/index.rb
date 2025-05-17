# frozen_string_literal: true

class PostsIndexController < MK::Controller
  route do |r|
    Post.all
  end
end