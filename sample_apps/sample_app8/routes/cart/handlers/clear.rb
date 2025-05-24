# frozen_string_literal: true

class CartClearHandler < MK::Handler
  handler do |r|
    {
      message: "Cart cleared",
      cart: model.to_hash
    }
  end
end