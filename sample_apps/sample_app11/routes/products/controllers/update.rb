# frozen_string_literal: true

class ProductsUpdateController < MK::Controller
  route do |r|
    product_id = r.params.fetch('id')
    product = Product[product_id]
    
    r.halt(404, { error: "Product not found" }.to_json) unless product
    
    # Verify category exists if category_id is being updated
    if r.params['category_id']
      category = Category[r.params['category_id']]
      r.halt(400, { error: "Category not found" }.to_json) unless category
    end
    
    # Update only provided fields
    update_params = {}
    %w[name description price stock_quantity sku category_id active].each do |param|
      update_params[param.to_sym] = r.params[param] if r.params.key?(param)
    end
    
    product.set(update_params)
    
    unless product.valid?
      r.halt(422, {
        error: "Validation failed",
        details: product.errors
      }.to_json)
    end
    
    product.save
    product
  end
end