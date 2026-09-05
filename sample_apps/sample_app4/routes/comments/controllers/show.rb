# frozen_string_literal: true

require_relative 'base'

module SampleApp4
  class CommentsShowController < CommentsController
    route do |r|
      find(r)
    end
  end
end
