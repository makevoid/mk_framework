# frozen_string_literal: true

require 'time'

module SampleApp6
  class WeatherIndexHandler < MK::Handler
    handler do |_r|
      model.map do |weather|
        {location: weather.location, fetched_at: weather.fetched_at.iso8601,
         cache_expires_at: (weather.fetched_at + 3600).iso8601,
         is_cached: weather.fetched_at > Time.now - 3600}
      end
    end
  end
end
