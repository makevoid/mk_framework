# frozen_string_literal: true

class EventsUpdateController < MK::Controller
  route do |r|
    event = Event[r.params['id']]
    r.halt(404, { message: "event not found" }) unless event

    event.title = r.params['title'] if r.params['title']
    event.description = r.params['description'] if r.params['description']
    event.start_time = r.params['start_time'] if r.params['start_time'] 
    event.end_time = r.params['end_time'] if r.params['end_time']
    event.location = r.params['location'] if r.params['location']
    event.all_day = r.params['all_day'] if r.params.key?('all_day')
    
    event
  end
end