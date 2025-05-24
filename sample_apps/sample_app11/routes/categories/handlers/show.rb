# frozen_string_literal: true

class CategoriesShowHandler < MK::Handler
  handler do |r|
    {
      category: model
    }
  end
end