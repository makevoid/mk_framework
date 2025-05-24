# frozen_string_literal: true

class CartsIndexHandler < MK::Handler
  handler do |r|
    { error: "Cart listing not supported" }
  end
end