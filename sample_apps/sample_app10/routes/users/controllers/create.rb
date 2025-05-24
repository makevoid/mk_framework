# frozen_string_literal: true

class UsersCreateController < MK::Controller
  route do |r|
    user = User.new(
      name: r.params['name'],
      email: r.params['email'],
      role: r.params['role'] || 'member',
      active: r.params.key?('active') ? r.params['active'] : true
    )
    
    # Set password if provided
    if r.params['password']
      user.password = r.params['password']
    end
    
    if user.valid?
      user.save
    end
    
    user
  end
end