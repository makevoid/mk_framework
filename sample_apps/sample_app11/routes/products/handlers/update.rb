# frozen_string_literal: true

class ProductsUpdateHandler < MK::Handler
  handler do |r|
    success do
      {
        product: model.to_hash.merge(
          in_stock: model.stock_quantity > 0,
          formatted_price: model.formatted_price
        ),
        message: "Product updated successfully"
      }
    end
  end
end