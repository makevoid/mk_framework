# frozen_string_literal: true

require_relative 'base'

module SampleApp7
  class CardsShowController < CardsController
    route do |r|
      record = find(r)
      {card: record, comments: paginate(record.comments_dataset, r)}
    end
  end
end
