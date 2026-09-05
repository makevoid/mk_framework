# frozen_string_literal: true

module SampleApp5
  class CardsUpdateHandler < MK::Handler
    handler do |r|
      {message: 'Card updated', card: model.public_attributes}
    end
  end
end
