# frozen_string_literal: true

class CardsShowHandler < MK::Handler
  route do |r|
    success do |r|
      r.response.status = 200
      model
    end
    
    error do |r, message|
      r.response.status = 404
      { error: message || "Card not found" }
    end
  end
end