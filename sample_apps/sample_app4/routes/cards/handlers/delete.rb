# frozen_string_literal: true

class CardsDeleteHandler < MK::Handler
  route do |r|
    success do |r|
      r.response.status = 200
      {
        message: "Card deleted successfully",
        card: model.to_hash
      }
    end

    error do |r, message|
      r.response.status = 404
      { error: message || "Card not found" }
    end
  end
end