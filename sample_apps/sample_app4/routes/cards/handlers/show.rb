# frozen_string_literal: true

class CardsShowHandler < MK::Handler
  route do |r|
    result = model

    {
      card: result[:card].values,
      comments: result[:comments].map(&:values)
    }
  end
end
