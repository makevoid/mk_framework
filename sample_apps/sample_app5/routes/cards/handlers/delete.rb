# frozen_string_literal: true

module SampleApp5
  class CardsDeleteHandler < MK::Handler
    handler do |r|
      {message: 'Card deleted successfully', card: model.slice(*Card.public_attributes_list)}
    end
  end
end
