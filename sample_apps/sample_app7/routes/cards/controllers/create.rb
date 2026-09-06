# frozen_string_literal: true

require_relative 'base'

module SampleApp7
  class CardsCreateController < CardsController
    route do |r|
      write_card(r, create: true)
    end
  end
end
