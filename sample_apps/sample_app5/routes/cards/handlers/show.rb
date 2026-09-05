# frozen_string_literal: true

module SampleApp5
  class CardsShowHandler < MK::Handler
    handler do |r|
      {card: model.fetch(:card).public_attributes, comments: model.fetch(:comments).map(&:public_attributes)}
    end
  end
end
