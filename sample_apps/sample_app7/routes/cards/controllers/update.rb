# frozen_string_literal: true

require_relative 'base'

module SampleApp7
  class CardsUpdateController < CardsController
    route do |r|
      write_card(r)
    end
  end
end
