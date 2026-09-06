# frozen_string_literal: true

module SampleApp7
  class CardsMoveHandler < MK::Handler
    handler do |_r|
      {message: 'Card moved', card: model.slice(*Card.public_attributes_list)}
    end
  end
end
