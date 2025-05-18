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

      it "returns an error" do
        get "/weather/London"
        expect(last_response.status).to eq 500
        expect(resp[:error]).to eq "API key not found"
      end

      after do
        # Reset the mock
        allow(WeatherApp).to receive(:api_key).and_call_original
      end
    end

    context "with successful API response mocked" do
      before do
        # Clean the database 
        DB[:weathers].delete

        # Create mock data
        @weather = Weather.create(
          location: "London",
          data: mock_weather_data,
          fetched_at: Time.now
        )
      end

      it "returns weather data for the location" do
        get "/weather/London"

        expect(last_response.status).to eq 200
        expect(resp[:location]).to eq "London"
        expect(resp[:hourly_forecast]).to be_an(Array)
        expect(resp[:hourly_forecast].length).to be <= 24
        expect(resp[:hourly_forecast][0]).to have_key(:temperature)
        expect(resp[:hourly_forecast][0]).to have_key(:weather)
        expect(resp[:cache_expires_at]).to be_a(String)
      end

      it "returns cached data if available and fresh" do
        first_time = Time.now
        get "/weather/London"
        
        # The fetched_at should be the same as we're using cached data
        first_timestamp = resp[:fetched_at]
        
        # Make another request - should still use cache
        sleep(1)
        get "/weather/London"
        second_timestamp = resp[:fetched_at]
        
        expect(first_timestamp).to eq(second_timestamp)
      end
    end

    context "with cache expired", :vcr do
      before do
        # Clean the database 
        DB[:weathers].delete

        # Create mock data with expired cache (more than an hour ago)
        @weather = Weather.create(
          location: "Paris",
          data: mock_weather_data,
          fetched_at: Time.now - 3601 # Just over an hour ago
        )
      end

      it "fetches new data when cache is expired", vcr: { cassette_name: "openweathermap/paris_forecast" } do
        original_fetched_at = @weather.fetched_at
        
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
        
        # Debug output to see what's happening
        puts "Response status: #{last_response.status}"
        puts "Response body: #{last_response.body}"
        
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

  describe "GET /weather" do
    before do
      # Clean the database 
      DB[:weathers].delete

      # Create sample data
      @london = Weather.create(
        location: "London",
        data: mock_weather_data,
        fetched_at: Time.now
      )
      
      @new_york = Weather.create(
        location: "New York",
        data: mock_weather_data,
        fetched_at: Time.now - 2000 # Still within the hour
      )
    end

    it "returns all known locations" do
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
  
  # Helper method to generate mock weather data
  def mock_weather_data
    {
      "cod" => "200",
      "message" => 0,
      "cnt" => 24,
      "list" => 24.times.map do |i|
        {
          "dt" => Time.now.to_i + (i * 3600),
          "main" => {
            "temp" => 15.0 + rand(-5..5),
            "feels_like" => 14.0 + rand(-5..5),
            "temp_min" => 12.0,
            "temp_max" => 18.0,
            "pressure" => 1012,
            "humidity" => 76
          },
          "weather" => [
            {
              "id" => 800,
              "main" => "Clear",
              "description" => "clear sky",
              "icon" => "01d"
            }
          ],
          "clouds" => {
            "all" => 0
          },
          "wind" => {
            "speed" => 2.68,
            "deg" => 167
          },
          "visibility" => 10000,
          "pop" => 0,
          "sys" => {
            "pod" => "d"
          },
          "dt_txt" => (Time.now + (i * 3600)).strftime("%Y-%m-%d %H:%M:%S")
        }
      end,
      "city" => {
        "id" => 2643743,
        "name" => "London",
        "coord" => {
          "lat" => 51.5085,
          "lon" => -0.1257
        },
        "country" => "GB",
        "population" => 1000000,
        "timezone" => 3600,
        "sunrise" => 1650600000,
        "sunset" => 1650650000
      }
    }.to_json
  end
end