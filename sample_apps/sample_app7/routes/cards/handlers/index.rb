# frozen_string_literal: true

module SampleApp7
  class CardsIndexHandler < MK::Handler
    handler do |r|
      model.map { |attributes| attributes.slice(*Card.public_attributes_list) }
    end
  end
end
