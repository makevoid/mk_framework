# frozen_string_literal: true

class ProductsCreateController < MK::Controller
  route do |r|
    # Verify category exists
    category = Category[r.params['category_id']]
    r.halt(400, { error: "Category not found" }.to_json) unless category
    
    product = Product.new(
      name: r.params['name'],
      description: r.params['description'],
      price: r.params['price'],
      stock_quantity: r.params['stock_quantity'] || 0,
      sku: r.params['sku'],
      category_id: r.params['category_id'],
      active: r.params.fetch('active', true)
    )
    
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