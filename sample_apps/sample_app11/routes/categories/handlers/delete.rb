# frozen_string_literal: true

class CategoriesDeleteHandler < MK::Handler
  handler do |r|
    success do
      {
        category_id: model[:id],
        message: "Category deleted successfully"
      }
    end
  end
end