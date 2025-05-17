# frozen_string_literal: true

class CardsIndexHandler < MK::Handler
  handler do |r|
    r.response.status = 200
    model.map(&:to_hash)
  end
end
