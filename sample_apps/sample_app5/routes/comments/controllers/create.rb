# frozen_string_literal: true

require_relative 'base'

module SampleApp5
  class CommentsCreateController < CommentsController
    route do |r|
      dataset(r) # Validate the URL parent before creating a child.
      Comment.new(r.input.permit(content: [String, NilClass], author: [String, NilClass]).merge(card_id: r.path_params.fetch(:card_id)))
    end
  end
end
