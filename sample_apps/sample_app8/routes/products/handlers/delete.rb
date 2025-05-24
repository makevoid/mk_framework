# frozen_string_literal: true

class ProductsDeleteHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Product deleted successfully",
        product: model.to_hash
      }
    end

    error do |r|
      r.response.status = 500
      {
        error: "Failed to delete product"
      }
    end
  end
end