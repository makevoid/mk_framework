# frozen_string_literal: true

class WeatherIndexHandler < MK::Handler
  handler do |r|
    success do |r|
      model.map do |weather|
        {
          location: weather.location,
          fetched_at: weather.fetched_at.strftime('%Y-%m-%d %H:%M:%S'),
          cache_expires_at: (weather.fetched_at + 3600).strftime('%Y-%m-%d %H:%M:%S'),
          is_cached: (weather.fetched_at > Time.now - 3600)
        }
      end
    end
  end
end