# frozen_string_literal: true

class UsersDeleteController < MK::Controller
  route do |r|
    user = User[r.params.fetch('id')]
    r.halt(404, { error: "User not found" }) if user.nil?
    
    user.destroy
    user
  end
end