# frozen_string_literal: true

require_relative 'base'

module SampleApp2
  class TodosUpdateController < TodosController
    route do |r|
      record = find(r)
      record.set(r.input.permit(title: [String, NilClass], description: [String, NilClass], completed: :boolean))
      persist(record)
    end
  end
end
