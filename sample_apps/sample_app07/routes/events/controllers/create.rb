# frozen_string_literal: true

class EventsCreateController < MK::Controller
  route do |r|
    Event.new(
      title: r.params['title'],
      description: r.params['description'],
      start_time: r.params['start_time'],
      end_time: r.params['end_time'],
      location: r.params['location'],
      all_day: r.params['all_day'] || false
    )
  end
end