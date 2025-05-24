# frozen_string_literal: true

class UsersUpdateController < MK::Controller
  route do |r|
    user_id = r.params.fetch('id')
    user = User[user_id]
    
    r.halt(404, { error: "User not found" }.to_json) unless user
    
    # Check if email already exists (if being updated)
    if r.params['email'] && r.params['email'] != user.email
      existing_user = User.where(email: r.params['email']).first
      if existing_user
        r.halt(400, { error: "Email already exists" }.to_json)
      end
    end
    
    # Update only provided fields
    update_params = {}
    %w[email password_hash first_name last_name].each do |param|
      update_params[param.to_sym] = r.params[param] if r.params.key?(param)
    end
    
    user.set(update_params)
    
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