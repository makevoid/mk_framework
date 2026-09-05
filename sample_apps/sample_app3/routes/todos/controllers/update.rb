# frozen_string_literal: true

require_relative 'base'

module SampleApp3
  class TodosUpdateController < TodosController
    route do |r|
      record = find(r)
      record.set(r.input.permit(title: [String, NilClass], description: [String, NilClass], completed: :boolean))
      record
    end
  end
end
