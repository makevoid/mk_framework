# frozen_string_literal: true

class ProductsShowController < MK::Controller
  route do |r|
    product_id = r.params.fetch('id')
    product = Product.join(:categories, id: :category_id)
                    .select_all(:products)
                    .select_append(:categories__name___category_name)
                    .where(products__id: product_id)
                    .first
    
    r.halt(404, { error: "Product not found" }.to_json) unless product
    
    product.to_hash.merge(
      category_name: product[:category_name],
      in_stock: product.stock_quantity > 0,
      formatted_price: product.formatted_price
    )
  end
end