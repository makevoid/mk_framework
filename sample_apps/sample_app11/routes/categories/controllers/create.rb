# frozen_string_literal: true

class CategoriesCreateController < MK::Controller
  route do |r|
    category = Category.new(
      name: r.params['name'],
      description: r.params['description']
    )
    
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