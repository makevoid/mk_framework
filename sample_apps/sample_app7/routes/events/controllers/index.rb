# frozen_string_literal: true

class EventsIndexController < MK::Controller
  route do |r|
    Event.all
  end
end