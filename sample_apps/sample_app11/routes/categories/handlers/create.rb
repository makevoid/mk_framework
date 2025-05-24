# frozen_string_literal: true

class CategoriesCreateHandler < MK::Handler
  handler do |r|
    success do
      response.status = 201
      {
        category: model.to_hash.merge(
          products_count: model.products_count,
          active_products_count: model.active_products_count
        ),
        message: "Category created successfully"
      }
    end
  end
end