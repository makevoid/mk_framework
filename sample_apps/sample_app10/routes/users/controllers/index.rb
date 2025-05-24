# frozen_string_literal: true

class UsersIndexController < MK::Controller
  route do |r|
    users = User.dataset
    
    # Filter by role if provided
    if r.params['role']
      users = users.where(role: r.params['role'])
    end
    
    # Filter by active status if provided
    if r.params['active']
      users = users.where(active: r.params['active'] == 'true')
    end
    
    users.all
  end
end