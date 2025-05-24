# frozen_string_literal: true

class UsersIndexHandler < MK::Handler
  handler do |r|
    {
      users: model.map(&:to_hash),
      total: model.count
    }
  end
end