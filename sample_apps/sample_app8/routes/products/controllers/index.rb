# frozen_string_literal: true

class ProductsIndexController < MK::Controller
  route do |r|
    products = Product.where(active: true)
    
    # Optional filtering
    if r.params['category']
      products = products.where(category: r.params['category'])
    end
    
    if r.params['min_price']
      products = products.where { price >= r.params['min_price'].to_f }
    end
    
    if r.params['max_price']
      products = products.where { price <= r.params['max_price'].to_f }
    end
    
    products.all
  end
end