# frozen_string_literal: true

class CardsIndexHandler < MK::Handler
  route do |r|
    {
      cards: model.map(&:values)
    }
  end
end
