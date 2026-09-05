# frozen_string_literal: true

require_relative 'base'

module SampleApp4
  class PostsShowController < PostsController
    route do |r|
      record = find(r)
      {post: record, comments: paginate(record.comments_dataset, r)}
    end
  end
end
