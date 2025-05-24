# frozen_string_literal: true

class ProductsCreateHandler < MK::Handler
  handler do |r|
    # If this is a Cart model (from nested route), handle cart response
    if model.is_a?(Cart)
      success do |r|
        {
          message: "Item added to cart",
          cart: model.to_hash
        }
      end

      error do |r|
        r.response.status = 422
        {
          error: "Failed to add item to cart",
          details: model.errors
        }
      end
    else
      # Otherwise handle as regular product creation
      success do |r|
        r.response.status = 201
        {
          message: "Product created successfully",
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
end