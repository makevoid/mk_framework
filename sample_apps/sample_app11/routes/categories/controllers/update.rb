# frozen_string_literal: true

class CategoriesUpdateController < MK::Controller
  route do |r|
    category_id = r.params.fetch('id')
    category = Category[category_id]
    
    r.halt(404, { error: "Category not found" }.to_json) unless category
    
    # Update only provided fields
    update_params = {}
    %w[name description].each do |param|
      update_params[param.to_sym] = r.params[param] if r.params.key?(param)
    end
    
    category.set(update_params)
    
    unless category.valid?
      r.halt(422, {
        error: "Validation failed",
        details: category.errors
      }.to_json)
    end
    
    category.save
    category
  end
end