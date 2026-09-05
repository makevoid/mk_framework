# frozen_string_literal: true

require 'excon'

module SampleApp6
  class WeatherShowController < Controller
    route do |r|
      location = r.path_params.fetch(:location)
      raise MK::BadRequest, 'Location is too long' if location.length > 100
      weather = Weather.where(location: location).first
      if weather && weather.fetched_at > Time.now - 3600
        weather
      else
        key = App.api_key
        r.halt(503, {error: 'Weather service is not configured'}) if key.nil? || key.empty?
        data = fetch_weather_data(location, key)
        now = Time.now
        # One atomic upsert avoids duplicate cache rows under concurrent requests.
        Weather.dataset.insert_conflict(target: :location, update: {data: data, fetched_at: now})
               .insert(location: location, data: data, fetched_at: now)
        Weather.where(location: location).first
      end
    end

    private

    def fetch_weather_data(location, key)
      response = Excon.get('https://api.openweathermap.org/data/2.5/forecast',
                           query: {q: location, appid: key, units: 'metric'},
                           connect_timeout: 3, read_timeout: 5, write_timeout: 5)
      raise MK::NotFound, 'Location not found' if response.status == 404
      raise MK::BadGateway unless response.status == 200

      data = JSON.parse(response.body)
      raise MK::BadGateway unless valid_forecast?(data)

      response.body
    rescue Excon::Error, JSON::ParserError
      raise MK::BadGateway
    end

    def valid_forecast?(data)
      return false unless data.is_a?(Hash) && data['list'].is_a?(Array)

      data['list'].all? do |period|
        period.is_a?(Hash) && period['dt'].is_a?(Numeric) &&
          period['main'].is_a?(Hash) && %w[temp feels_like humidity].all? { |key| period['main'][key].is_a?(Numeric) } &&
          period['wind'].is_a?(Hash) && %w[speed deg].all? { |key| period['wind'][key].is_a?(Numeric) } &&
          period['weather'].is_a?(Array) && period['weather'].first.is_a?(Hash) &&
          %w[main description icon].all? { |key| period['weather'].first[key].is_a?(String) }
      end
    end
  end
end
