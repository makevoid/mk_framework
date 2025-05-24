# frozen_string_literal: true

class CategoriesIndexController < MK::Controller
  route do |r|
    categories = Category.order(:name)
    
    # Search by name if specified
    if r.params['search']
      search_term = "%#{r.params['search']}%"
      categories = categories.where(Sequel.ilike(:name, search_term))
    end
    
    categories.all.map do |category|
      category.to_hash.merge(
        products_count: category.products_count,
        active_products_count: category.active_products_count
      )
    end
  end
end