# frozen_string_literal: true

class WeatherShowController < MK::Controller
  route do |r|
    location = r.params.fetch('location')
    weather = Weather.where(location: location).first
    
    # Check if we have cached data that's still fresh (less than 1 hour old)
    if weather && weather.fetched_at > Time.now - 3600
      return weather
    end
    
    # Get new data from OpenWeatherMap API
    api_key = WeatherApp.api_key
    r.halt(500, { error: "API key not found" }) unless api_key
    
    uri = URI("https://api.openweathermap.org/data/2.5/forecast")
    params = {
      q: location,
      appid: api_key,
      units: 'metric'
    }
    uri.query = URI.encode_www_form(params)
    
    begin
      response = Net::HTTP.get_response(uri)
      
      if response.is_a?(Net::HTTPSuccess)
        data = response.body
        
        # Create or update the weather record
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
        
        return weather
      else
        r.halt(response.code.to_i, { error: "OpenWeatherMap API error", details: response.body })
      end
    rescue => e
      r.halt(500, { error: "Error fetching weather data", details: e.message })
    end
  end
end