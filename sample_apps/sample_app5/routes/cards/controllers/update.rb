# frozen_string_literal: true

require_relative 'base'

module SampleApp5
  class CardsUpdateController < CardsController
    route do |r|
      record = find(r)
      record.set(r.input.permit(title: [String, NilClass], description: [String, NilClass], status: String))
      record
    end
  end
end
