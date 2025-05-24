# frozen_string_literal: true

class ProductsIndexHandler < MK::Handler
  handler do |r|
    {
      products: model,
      total_count: model.length,
      filters_applied: {
        category_id: r.params['category_id'],
        search: r.params['search'],
        in_stock: r.params['in_stock']
      }
    }
  end
end