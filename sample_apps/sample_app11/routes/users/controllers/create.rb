# frozen_string_literal: true

class UsersCreateController < MK::Controller
  route do |r|
    # Check if email already exists
    existing_user = User.where(email: r.params['email']).first
    if existing_user
      r.halt(400, { error: "Email already exists" }.to_json)
    end
    
    user = User.new(
      email: r.params['email'],
      password_hash: r.params['password_hash'],
      first_name: r.params['first_name'],
      last_name: r.params['last_name']
    )
    
    unless user.valid?
      r.halt(422, {
        error: "Validation failed",
        details: user.errors
      }.to_json)
    end
    
    user.save
    user
  end
end