# frozen_string_literal: true

class CategoriesShowController < MK::Controller
  route do |r|
    category_id = r.params.fetch('id')
    category = Category[category_id]
    
    r.halt(404, { error: "Category not found" }.to_json) unless category
    
    category.to_hash.merge(
      products_count: category.products_count,
      active_products_count: category.active_products_count,
      products: category.products.where(active: true).map(&:to_hash)
    )
  end
end