# frozen_string_literal: true

require_relative 'base'

module SampleApp7
  class CardsIndexController < CardsController
    route do |r|
      page = r.page
      filtered_dataset(r).limit(page[:limit], page[:offset]).all
    end
  end
end
