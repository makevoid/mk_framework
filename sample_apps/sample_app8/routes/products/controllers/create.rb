# frozen_string_literal: true

class ProductsCreateController < MK::Controller
  route do |r|
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