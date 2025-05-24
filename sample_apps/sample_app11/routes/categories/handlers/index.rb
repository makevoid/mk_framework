# frozen_string_literal: true

class CategoriesIndexHandler < MK::Handler
  handler do |r|
    {
      categories: model,
      total_count: model.length,
      search_applied: r.params['search']
    }
  end
end