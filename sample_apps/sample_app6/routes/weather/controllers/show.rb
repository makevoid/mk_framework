# frozen_string_literal: true
class WeatherShowController < MK::Controller

  HANDLE_RESPONSE = ->(response:, location:, r:) do
    if response.is_a?(Hash) && response[:error]
      r.halt(400, { error: "Error fetching weather data", details: response[:message] })
    elsif response.status == 200
      self.store_weather_data(location, response.body)
    else
      r.halt(500, { error: "OpenWeatherMap API error", details: response.body })
    end
  end

  route do |r|
    location = r.params.fetch('id')
    weather = Weather.where(location: location).first

    if weather && weather.fetched_at > Time.now - 3600
      weather
    else
      api_key = WeatherApp.api_key
      r.halt(500, { error: "API key not found" }) unless api_key

      response = fetch_weather_data(location, api_key)
      HANDLE_RESPONSE.(response: response, location: location, r: r)
    end
  end

  private

  def fetch_weather_data(location, api_key)
    url = "https://api.openweathermap.org/data/2.5/forecast"
    params = {
      q: location,
      appid: api_key,
      units: 'metric'
    }

    begin
      Excon.get(
        url,
        query: params,
        headers: { 'Content-Type' => 'application/json' }
      )
    rescue Excon::Error => e
      { error: true, status: 500, message: e.message }
    end
  end

  def self.store_weather_data(location, data)
    weather = Weather.where(location: location).first

    if weather
      weather.data = data
      weather.fetched_at = Time.now
      weather.save
    else
      weather = Weather.create(
        location: location,
        data: data,
        fetched_at: Time.now
      )
    end

    weather
  end
end
