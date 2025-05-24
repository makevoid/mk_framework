# frozen_string_literal: true

class ProductsUpdateHandler < MK::Handler
  handler do |r|
    success do |r|
      {
        message: "Product updated successfully",
        product: model.to_hash
      }
    end

    error do |r|
      r.response.status = 422
      {
        error: "Validation failed",
        details: model.errors
      }
    end
  end
end