# frozen_string_literal: true

class CardsUpdateHandler < MK::Handler
  route do |r|
    success do |r|
      r.response.status = 200
      {
        message: "Card updated",
        card: model.to_hash
      }
    end

    error do |r, message|
      if message == "Card not found"
        r.response.status = 404
        { error: message }
      else
        r.response.status = 400
        {
          error: "Validation failed!",
          details: model.errors
        }
      end
    end
  end
end