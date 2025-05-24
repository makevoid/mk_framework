# frozen_string_literal: true

class CartsShowHandler < MK::Handler
  handler do |r|
    model.to_hash
  end
end