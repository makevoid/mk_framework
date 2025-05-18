# frozen_string_literal: true

class WeatherShowHandler < MK::Handler
  handler do |r|
    raw_data = JSON.parse(model.data)

    # Format the weather data to be more useful
    hourly_forecast = raw_data['list'].take(24) # Get forecast for next 24 hours

    formatted_data = hourly_forecast.map do |hour|
      {
        time: Time.at(hour['dt']).strftime('%Y-%m-%d %H:%M:%S'),
        temperature: hour['main']['temp'],
        feels_like: hour['main']['feels_like'],
        humidity: hour['main']['humidity'],
        weather: {
          main: hour['weather'][0]['main'],
          description: hour['weather'][0]['description'],
          icon: hour['weather'][0]['icon']
        },
        wind: {
          speed: hour['wind']['speed'],
          direction: hour['wind']['deg']
        }
      }
    end

    {
      location: model.location,
      hourly_forecast: formatted_data,
      fetched_at: model.fetched_at.strftime('%Y-%m-%d %H:%M:%S'),
      cache_expires_at: (model.fetched_at + 3600).strftime('%Y-%m-%d %H:%M:%S')
    }
  end
end
