# frozen_string_literal: true

module SampleApp7
  class BoardIndexHandler < MK::Handler
    handler do |_r|
      model.merge(columns: model.fetch(:columns).map do |column|
        column.merge(cards: column.fetch(:cards).map { |card| card.slice(*Card.public_attributes_list) })
      end)
    end
  end
end
