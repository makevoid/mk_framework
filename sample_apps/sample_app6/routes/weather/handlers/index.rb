# frozen_string_literal: true

require 'time'

module SampleApp6
  class WeatherIndexHandler < MK::Handler
    handler do |_r|
      model.map do |weather|
        {location: weather.fetch(:location), fetched_at: weather.fetch(:fetched_at).iso8601,
         cache_expires_at: (weather.fetch(:fetched_at) + 3600).iso8601,
         is_cached: weather.fetch(:fetched_at) > Time.now - 3600}
      end
    end
  end
end
