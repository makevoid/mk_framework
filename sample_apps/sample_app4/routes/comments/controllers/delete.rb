# frozen_string_literal: true

require_relative 'base'

module SampleApp4
  class CommentsDeleteController < CommentsController
    route do |r|
      destroy(find(r))
    end
  end
end
