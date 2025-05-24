# frozen_string_literal: true

class UsersShowController < MK::Controller
  route do |r|
    user = User[r.params.fetch('id')]
    r.halt(404, { error: "User not found" }) if user.nil?
    
    user
  end
end