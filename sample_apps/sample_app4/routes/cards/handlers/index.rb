# frozen_string_literal: true

class CardsIndexHandler < MK::Handler
  route do |r|
    r.response.status = 200
    models.map(&:to_hash)
  end
end
