# frozen_string_literal: true

require 'spec_helper'

describe "Weather API" do
  before(:all) do
    # Make sure we have an API key for testing
    WeatherApp.api_key
  end

  describe "GET /weather/:location" do
    context "with successful API response", :vcr do
      before do
        DB[:weathers].delete
      end

      it "returns weather data for the location", vcr: { cassette_name: "openweathermap/london_forecast" } do
        get "/weather/London"

        expect(last_response.status).to eq 200
        expect(resp[:location]).to eq "London"
        expect(resp[:hourly_forecast]).to be_an(Array)
        expect(resp[:hourly_forecast].length).to be <= 24
        expect(resp[:hourly_forecast][0]).to have_key(:temperature)
        expect(resp[:hourly_forecast][0]).to have_key(:weather)
        expect(resp[:cache_expires_at]).to be_a(String)
      end

      it "returns cached data if available and fresh", vcr: { cassette_name: "openweathermap/london_forecast_cached" } do
        get "/weather/London"

        first_timestamp = resp[:fetched_at]

        get "/weather/London"
        second_timestamp = resp[:fetched_at]

        expect(first_timestamp).to eq(second_timestamp)
      end
    end

    context "with cache expired", :vcr do
      before do
        # Clean the database
        DB[:weathers].delete
      end

      it "fetches new data when cache is expired", vcr: { cassette_name: "openweathermap/paris_forecast_expired" } do
        response = WeatherShowController.new.send(:fetch_weather_data, "Paris", WeatherApp.api_key)
        weather = WeatherShowController.store_weather_data("Paris", response.body)

        original_fetched_at = Time.now - 3601 # Just over an hour ago
        weather.update(fetched_at: original_fetched_at)

        get "/weather/Paris"

        expect(last_response.status).to eq 200
        fetched_time = DateTime.parse(resp[:fetched_at])
        original_time = original_fetched_at.to_datetime

        expect(fetched_time).to be > original_time
      end
    end

    context "with a new location", :vcr do
      before do
        DB[:weathers].delete
      end

      it "fetches data for a new location", vcr: { cassette_name: "openweathermap/tokyo_forecast" } do
        get "/weather/Tokyo"

        expect(last_response.status).to eq 200
        expect(resp[:location]).to eq "Tokyo"
        expect(resp[:hourly_forecast]).to be_an(Array)
        expect(resp[:hourly_forecast].length).to be <= 24
        expect(resp[:hourly_forecast][0]).to have_key(:temperature)
        expect(resp[:hourly_forecast][0]).to have_key(:weather)
      end
    end

    context "with invalid location", :vcr do
      it "returns an error when location doesn't exist", vcr: { cassette_name: "openweathermap/invalid_location" } do
        get "/weather/NonExistentCity123456"

        expect(last_response.status).not_to eq 200
        expect(resp).to have_key(:error)
      end
    end
  end

  describe "GET /weather", :vcr do
    before do
      DB[:weathers].delete
    end

    it "returns all known locations", vcr: { cassette_name: "openweathermap/multiple_locations" } do
      response = WeatherShowController.new.send(:fetch_weather_data, "London", WeatherApp.api_key)
      WeatherShowController.store_weather_data("London", response.body)

      response = WeatherShowController.new.send(:fetch_weather_data, "New York", WeatherApp.api_key)
      new_york = WeatherShowController.store_weather_data("New York", response.body)
      new_york.update(fetched_at: Time.now - 2000)

      get "/weather"

      expect(last_response.status).to eq 200
      expect(resp.length).to eq 2

      locations = resp.map { |w| w[:location] }
      expect(locations).to include("London")
      expect(locations).to include("New York")

      cache_status = resp.map { |w| w[:is_cached] }
      expect(cache_status).to all(be true)
    end
  end
end
