# frozen_string_literal: true

class ProductsCreateController < MK::Controller
  route do |r|
    # If this is a nested cart/products request, delegate to cart logic
    if r.params.key?('cart_id')
      session_id = r.params.fetch('cart_id')
      product_id = r.params.fetch('product_id')
      quantity = (r.params['quantity'] || 1).to_i
      
      r.halt(422, { error: "Quantity must be positive" }) if quantity <= 0
      
      # Find or create cart
      cart = Cart.find(session_id: session_id) || Cart.create(session_id: session_id)
      
      # Find product
      product = Product[product_id]
      r.halt(404, { error: "Product not found" }) if product.nil?
      r.halt(422, { error: "Product not available" }) unless product.available?
      r.halt(422, { error: "Insufficient stock" }) if product.stock < quantity
      
      # Add item to cart
      cart.add_item(product, quantity)
      
      # Return cart and don't continue to regular product creation
      cart
    else
      # Regular product creation
      Product.new(
        name: r.params['name'],
        description: r.params['description'],
        price: r.params['price'],
        stock: r.params['stock'] || 0,
        sku: r.params['sku'],
        image_url: r.params['image_url'],
        active: r.params.fetch('active', true)
      )
    end
  end
end