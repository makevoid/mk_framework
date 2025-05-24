# frozen_string_literal: true

class ProductsCreateHandler < MK::Handler
  handler do |r|
    success do
      response.status = 201
      {
        product: model.to_hash.merge(
          in_stock: model.stock_quantity > 0,
          formatted_price: model.formatted_price
        ),
        message: "Product created successfully"
      }
    end
  end
end