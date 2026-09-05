# frozen_string_literal: true

require 'time'

module SampleApp6
  class WeatherShowHandler < MK::Handler
    handler do |_r|
      forecast = JSON.parse(model.fetch(:data)).fetch('list').first(8).map do |period|
        {time: Time.at(period.fetch('dt')).utc.iso8601,
         temperature: period.fetch('main').fetch('temp'),
         feels_like: period.fetch('main').fetch('feels_like'),
         humidity: period.fetch('main').fetch('humidity'),
         weather: period.fetch('weather').first.slice('main', 'description', 'icon'),
         wind: {speed: period.fetch('wind').fetch('speed'), direction: period.fetch('wind').fetch('deg')}}
      end
      {location: model.fetch(:location), forecast: forecast,
       fetched_at: model.fetch(:fetched_at).iso8601, cache_expires_at: (model.fetch(:fetched_at) + 3600).iso8601}
    end
  end
end
