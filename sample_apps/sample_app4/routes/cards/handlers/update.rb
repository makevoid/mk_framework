# frozen_string_literal: true

class CardsUpdateHandler < MK::Handler
  route do |r|
    r.response.status = 200
    {
      message: "Card updated",
      card: model.values
    }
  end
end
