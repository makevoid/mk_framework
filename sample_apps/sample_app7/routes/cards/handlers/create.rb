# frozen_string_literal: true

module SampleApp7
  class CardsCreateHandler < MK::Handler
    handler do |r|
      r.response.status = 201
      {message: 'Card created', card: model.slice(*Card.public_attributes_list)}
    end
  end
end
