# frozen_string_literal: true

require_relative 'base'

module SampleApp4
  class PostsDeleteController < PostsController
    route do |r|
      destroy(find(r))
    end
  end
end
