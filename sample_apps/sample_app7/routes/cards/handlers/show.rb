# frozen_string_literal: true

module SampleApp7
  class CardsShowHandler < MK::Handler
    handler do |r|
      {card: model.fetch(:card).slice(*Card.public_attributes_list), comments: model.fetch(:comments).map { |comment| comment.slice(*Comment.public_attributes_list) }}
    end
  end
end
