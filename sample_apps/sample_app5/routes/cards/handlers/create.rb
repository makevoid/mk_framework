# frozen_string_literal: true

module SampleApp5
  class CardsCreateHandler < MK::Handler
    handler do |r|
      r.response.status = 201
      {message: 'Card created', card: model.public_attributes}
    end
  end
end
