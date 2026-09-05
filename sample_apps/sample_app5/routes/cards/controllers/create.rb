# frozen_string_literal: true

require_relative 'base'

module SampleApp5
  class CardsCreateController < CardsController
    route do |r|
      Card.new(r.input.permit(title: [String, NilClass], description: [String, NilClass], status: String))
    end
  end
end
