# frozen_string_literal: true

require_relative 'base'

module SampleApp4
  class PostsCreateController < PostsController
    route do |r|
      persist(Post.new(r.input.permit(title: [String, NilClass], description: [String, NilClass])))
    end
  end
end
