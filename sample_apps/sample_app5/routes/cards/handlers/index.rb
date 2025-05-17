# frozen_string_literal: true

class CardsIndexHandler < MK::Handler
  handler do |r|
    model.map(&:to_hash)
  end
end
