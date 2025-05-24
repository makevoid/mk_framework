# frozen_string_literal: true

class CartUpdateItemHandler < MK::Handler
  handler do |r|
    {
      message: "Cart item updated",
      cart: model.to_hash
    }
  end
end