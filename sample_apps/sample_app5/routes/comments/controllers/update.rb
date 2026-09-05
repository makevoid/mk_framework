# frozen_string_literal: true

require_relative 'base'

module SampleApp5
  class CommentsUpdateController < CommentsController
    route do |r|
      record = find(r)
      record.set(r.input.permit(content: [String, NilClass], author: [String, NilClass]))
      record
    end
  end
end
