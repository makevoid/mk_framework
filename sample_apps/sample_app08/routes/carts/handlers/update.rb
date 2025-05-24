# frozen_string_literal: true

class CartsUpdateHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Cart updated successfully",
        cart: model.to_hash
      }
    end

    error do |r|
      { error: r.params['error'] || "Failed to update cart" }
    end
  end
end