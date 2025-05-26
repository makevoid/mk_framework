# frozen_string_literal: true

class UsersUpdateController < MK::Controller
  route do |r|
    user = User[r.params.fetch('id')]
    r.halt(404, { error: "User not found" }) if user.nil?
    
    # FIXME
    update_params = {}
    update_params[:name] = r.params['name'] if r.params.key?('name')
    update_params[:email] = r.params['email'] if r.params.key?('email')
    update_params[:role] = r.params['role'] if r.params.key?('role')
    update_params[:active] = r.params['active'] if r.params.key?('active')
    
    # Update password if provided
    if r.params['password']
      user.password = r.params['password']
    end
    
    user.update(update_params) unless update_params.empty?
    user
  end
end