# frozen_string_literal: true

module SampleApp4
  class PostsCreateController < Controller
    route do |r|
      Post.new(r.input.permit(title: [String, NilClass], description: [String, NilClass]))
    end
  end
end
