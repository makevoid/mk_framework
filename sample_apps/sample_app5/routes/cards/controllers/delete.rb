# frozen_string_literal: true

require_relative 'base'

module SampleApp5
  class CardsDeleteController < CardsController
    route do |r|
      destroy(find(r))
    end
  end
end
