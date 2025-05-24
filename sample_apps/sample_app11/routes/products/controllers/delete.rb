# frozen_string_literal: true

class ProductsDeleteController < MK::Controller
  route do |r|
    product_id = r.params.fetch('id')
    product = Product[product_id]
    
    r.halt(404, { error: "Product not found" }.to_json) unless product
    
    # Check if product is referenced in orders or cart items
    if product.order_items.count > 0
      r.halt(400, { 
        error: "Cannot delete product that has been ordered" 
      }.to_json)
    end
    
    # Remove from any carts first
    product.cart_items.each(&:delete)
    
    product.delete
    { id: product_id.to_i }
  end
end