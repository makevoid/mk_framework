# frozen_string_literal: true

class ProductsUpdateController < MK::Controller
  route do |r|
    product = Product[r.params.fetch('id')]
    
    r.halt(404, { error: "Product not found" }) if product.nil?
    
    params = r.params
    
    product.name = params['name'] if params.key?('name')
    product.description = params['description'] if params.key?('description')
    product.price = params['price'] if params.key?('price')
    product.stock = params['stock'] if params.key?('stock')
    product.sku = params['sku'] if params.key?('sku')
    product.image_url = params['image_url'] if params.key?('image_url')
    product.active = params['active'] if params.key?('active')
    
    product
  end
end