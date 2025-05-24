# frozen_string_literal: true

class CategoriesDeleteController < MK::Controller
  route do |r|
    category_id = r.params.fetch('id')
    category = Category[category_id]
    
    r.halt(404, { error: "Category not found" }.to_json) unless category
    
    # Check if category has products
    if category.products.count > 0
      r.halt(400, { 
        error: "Cannot delete category that contains products" 
      }.to_json)
    end
    
    category.delete
    { id: category_id.to_i }
  end
end