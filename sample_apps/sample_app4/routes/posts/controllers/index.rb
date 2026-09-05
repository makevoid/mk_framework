# frozen_string_literal: true

require_relative 'base'

module SampleApp4
  class PostsIndexController < PostsController
    route do |r|
      paginate(dataset(r), r)
    end
  end
end
