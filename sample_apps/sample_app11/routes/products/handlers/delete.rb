# frozen_string_literal: true

class ProductsDeleteHandler < MK::Handler
  handler do |r|
    success do
      {
        product_id: model[:id],
        message: "Product deleted successfully"
      }
    end
  end
end