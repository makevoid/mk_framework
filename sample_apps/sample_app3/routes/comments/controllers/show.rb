# frozen_string_literal: true

class CommentsShowController < MK::Controller
  route do |r|
    Comment[r.params.fetch('id')]
  end
end