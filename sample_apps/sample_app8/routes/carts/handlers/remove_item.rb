# frozen_string_literal: true

class CartRemoveItemHandler < MK::Handler
  handler do |r|
    {
      message: "Item removed from cart",
      cart: model.to_hash
    }
  end
end