# frozen_string_literal: true

class CartsProductsCreateHandler < MK::Handler
  handler do |r|
    {
      message: "Item added to cart",
      cart: model.to_hash
    }
  end
end