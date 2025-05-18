# frozen_string_literal: true

require 'spec_helper'

describe "Weather API" do
  before(:all) do
    # Make sure we have an API key for testing
    WeatherApp.api_key
  end

  describe "GET /weather/:location" do
    context "when API key is missing" do
      before do
        allow(WeatherApp).to receive(:api_key).and_return(nil)
      end

      it "returns an error", vcr: { record: :none } do
        VCR.turned_off do
          WebMock.allow_net_connect!
          get "/weather/London"
          expect(last_response.status).to eq 500
          expect(resp[:error]).to eq "API key not found"
          WebMock.disable_net_connect!
        end
      end

      after do
        # Reset the mock
        allow(WeatherApp).to receive(:api_key).and_call_original
      end
    end

    context "with successful API response", :vcr do
      before do
        # Clean the database
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
        # First request to populate the cache
        get "/weather/London"
        
        # The fetched_at from the first request
        first_timestamp = resp[:fetched_at]
        
        # Make another request - should use cache instead of making a new API call
        get "/weather/London"
        second_timestamp = resp[:fetched_at]
        
        # Timestamps should be the same since we're using cached data
        expect(first_timestamp).to eq(second_timestamp)
      end
    end

    context "with cache expired", :vcr do
      before do
        # Clean the database
        DB[:weathers].delete
      end

      it "fetches new data when cache is expired", vcr: { cassette_name: "openweathermap/paris_forecast_expired" } do
        # First create an expired record
        response = WeatherShowController.new.send(:fetch_weather_data, "Paris", WeatherApp.api_key)
        weather = WeatherShowController.store_weather_data("Paris", response.body)
        
        # Manually update the fetched_at time to make it appear expired
        original_fetched_at = Time.now - 3601 # Just over an hour ago
        weather.update(fetched_at: original_fetched_at)
        
        # Now make the request that should refresh the data
        get "/weather/Paris"

        # Should have updated the timestamp
        expect(last_response.status).to eq 200
        fetched_time = DateTime.parse(resp[:fetched_at])
        original_time = original_fetched_at.to_datetime

        # The new timestamp should be more recent
        expect(fetched_time).to be > original_time
      end
    end

    context "with a new location", :vcr do
      before do
        # Clean the database to ensure the location doesn't exist
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
      # Clean the database
      DB[:weathers].delete
    end

    it "returns all known locations", vcr: { cassette_name: "openweathermap/multiple_locations" } do
      # Create real weather data for London
      response = WeatherShowController.new.send(:fetch_weather_data, "London", WeatherApp.api_key)
      WeatherShowController.store_weather_data("London", response.body)

      # Create real weather data for New York 
      response = WeatherShowController.new.send(:fetch_weather_data, "New York", WeatherApp.api_key)
      new_york = WeatherShowController.store_weather_data("New York", response.body)
      # Set the fetched_at time to be older but still within cache timeout
      new_york.update(fetched_at: Time.now - 2000) # Still within the hour

      get "/weather"

      expect(last_response.status).to eq 200
      expect(resp.length).to eq 2

      locations = resp.map { |w| w[:location] }
      expect(locations).to include("London")
      expect(locations).to include("New York")

      # All should indicate they're still cached
      cache_status = resp.map { |w| w[:is_cached] }
      expect(cache_status).to all(be true)
    end
  end
end