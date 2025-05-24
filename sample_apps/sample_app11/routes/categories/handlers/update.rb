# frozen_string_literal: true

class CategoriesUpdateHandler < MK::Handler
  handler do |r|
    success do
      {
        category: model.to_hash.merge(
          products_count: model.products_count,
          active_products_count: model.active_products_count
        ),
        message: "Category updated successfully"
      }
    end
  end
end