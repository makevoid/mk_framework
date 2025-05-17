# frozen_string_literal: true

class WeatherIndexController < MK::Controller
  route do |r|
    Weather.all
  end
end