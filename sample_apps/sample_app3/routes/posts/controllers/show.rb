# frozen_string_literal: true

class PostsShowController < MK::Controller
  route do |r|
    Post[r.params.fetch('id')]
  end
end