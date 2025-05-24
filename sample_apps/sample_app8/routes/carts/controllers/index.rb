# frozen_string_literal: true

class CartsIndexController < MK::Controller
  route do |r|
    # This endpoint is not commonly used for carts since they're session-based
    # But including for CRUD completeness
    r.halt(404, { error: "Cart listing not supported" })
  end
end