# frozen_string_literal: true

require_relative 'base'

module SampleApp4
  class PostsUpdateController < PostsController
    route do |r|
      record = find(r)
      record.set(r.input.permit(title: [String, NilClass], description: [String, NilClass]))
      persist(record)
    end
  end
end
