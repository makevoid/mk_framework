# frozen_string_literal: true

require_relative 'base'

module SampleApp7
  class CardsDeleteController < CardsController
    route do |r|
      delete_card(r)
    end
  end
end
