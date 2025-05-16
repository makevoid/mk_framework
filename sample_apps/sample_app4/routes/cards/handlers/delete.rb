# frozen_string_literal: true

class CardsDeleteHandler < MK::Handler
  route do |r|
    r.response.status = 200
    {
      message: "Card deleted successfully",
      card: model.values
    }
  end
end
