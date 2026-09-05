# frozen_string_literal: true

require_relative 'base'

module SampleApp4
  class CommentsCreateController < CommentsController
    route do |r|
      dataset(r) # Validate the URL parent before creating a child.
      persist(Comment.new(r.input.permit(content: [String, NilClass], author: [String, NilClass]).merge(post_id: r.path_params.fetch(:post_id))))
    end
  end
end
