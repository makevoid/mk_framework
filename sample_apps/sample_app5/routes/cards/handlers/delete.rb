# frozen_string_literal: true

module SampleApp5
  class CardsDeleteHandler < MK::Handler
    handler do |r|
      {message: 'Card deleted successfully', card: model.public_attributes}
    end
  end
end
