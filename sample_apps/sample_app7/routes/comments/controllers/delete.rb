# frozen_string_literal: true

require_relative 'base'

module SampleApp7
  class CommentsDeleteController < CommentsController
    route do |r|
      find(r)
    end
  end
end
