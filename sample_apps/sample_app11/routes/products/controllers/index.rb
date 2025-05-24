# frozen_string_literal: true

class ProductsIndexController < MK::Controller
  route do |r|
    products = Product.join(:categories, id: :category_id)
                     .select_all(:products)
                     .select_append(:categories__name___category_name)
                     .where(products__active: true)
                     .order(:products__name)
    
    # Filter by category if specified
    if r.params['category_id']
      products = products.where(products__category_id: r.params['category_id'])
    end
    
    # Search by name if specified
    if r.params['search']
      search_term = "%#{r.params['search']}%"
      products = products.where(Sequel.ilike(:products__name, search_term))
    end
    
    # Filter by availability
    if r.params['in_stock'] == 'true'
      products = products.where { products__stock_quantity > 0 }
    end
    
    products.all.map do |product|
      product.to_hash.merge(
        category_name: product[:category_name],
        in_stock: product.stock_quantity > 0,
        formatted_price: product.formatted_price
      )
    end
  end
end