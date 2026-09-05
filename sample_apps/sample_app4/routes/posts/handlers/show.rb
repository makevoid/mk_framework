# frozen_string_literal: true

module SampleApp4
  class PostsShowHandler < MK::Handler
    handler do |r|
      {post: model.fetch(:post).public_attributes, comments: model.fetch(:comments).map(&:public_attributes)}
    end
  end
end
