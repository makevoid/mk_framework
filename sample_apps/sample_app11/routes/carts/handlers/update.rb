# frozen_string_literal: true

class CartsUpdateHandler < MK::Handler
  handler do |r|
    success do
      {
        cart_item: model.to_hash.merge(
          product_name: model.product.name,
          product_price: model.product.price,
          total_price: model.total_price,
          can_fulfill: model.can_fulfill?
        ),
        message: "Cart item updated successfully"
      }
    end
  end
end