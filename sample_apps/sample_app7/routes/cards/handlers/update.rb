# frozen_string_literal: true

module SampleApp7
  class CardsUpdateHandler < MK::Handler
    handler do |r|
      {message: 'Card updated', card: model.slice(*Card.public_attributes_list)}
    end
  end
end
