# frozen_string_literal: true

class UsersIndexHandler < MK::Handler
  handler do |r|
    {
      users: model,
      total_count: model.length,
      search_applied: r.params['search']
    }
  end
end