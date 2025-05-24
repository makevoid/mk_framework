# frozen_string_literal: true

class CartsDeleteHandler < MK::Handler
  handler do |r|
    success do
      {
        cart_item_id: model[:id],
        user_id: model[:user_id],
        message: "Item removed from cart successfully"
      }
    end
  end
end