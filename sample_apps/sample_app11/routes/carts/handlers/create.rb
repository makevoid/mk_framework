# frozen_string_literal: true

class CartsCreateHandler < MK::Handler
  handler do |r|
    success do
      response.status = 201
      {
        cart_item: model.to_hash.merge(
          product_name: model.product.name,
          product_price: model.product.price,
          total_price: model.total_price,
          can_fulfill: model.can_fulfill?
        ),
        message: "Item added to cart successfully"
      }
    end
  end
end