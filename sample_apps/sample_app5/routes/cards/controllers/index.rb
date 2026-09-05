# frozen_string_literal: true

require_relative 'base'

module SampleApp5
  class CardsIndexController < CardsController
    route do |r|
      paginate(dataset(r), r)
    end
  end
end
