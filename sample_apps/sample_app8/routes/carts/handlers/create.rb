# frozen_string_literal: true

class CartsCreateHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Item added to cart",
        cart: model.to_hash
      }
    end

    error do |r|
      { error: r.params['error'] || "Failed to add item to cart" }
    end
  end
end