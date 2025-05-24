# frozen_string_literal: true

class ProductsShowController < MK::Controller
  route do |r|
    product = Product[r.params.fetch('id')]
    
    r.halt(404, { error: "Product not found" }) if product.nil?
    
    product
  end
end