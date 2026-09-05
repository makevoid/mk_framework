# frozen_string_literal: true

require_relative '../spec_helper'

module SampleApp6
  RSpec.describe 'Weather API' do
    before do
      Weather.dataset.delete
      @period = {dt: 1_800_000_000, main: {temp: 15, feels_like: 14, humidity: 76},
                 weather: [{main: 'Clear', description: 'clear sky', icon: '01d'}],
                 wind: {speed: 2.5, deg: 100}}
      @data = JSON.generate(list: Array.new(10) { |i| @period.merge(dt: @period[:dt] + i * 10_800) })
      @url = 'https://api.openweathermap.org/data/2.5/forecast'
    end

    def upstream(location)
      stub_request(:get, @url).with(query: {q: location, appid: 'test-weather-key', units: 'metric'})
    end

    it 'reports a missing API key without reading a personal key file' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('OPENWEATHERMAP_API_KEY').and_return(nil)
      get '/weather/London'
      expect(last_response.status).to eq(503)
      expect(resp[:error]).to eq('Weather service is not configured')
    end

    it 'fetches a new location and returns eight three-hour periods' do
      request = upstream('London').to_return(status: 200, body: @data)
      get '/weather/London'
      expect(last_response.status).to eq(200)
      expect(resp[:forecast].length).to eq(8)
      expect(resp[:forecast][0][:temperature]).to eq(15)
      expect(Time.iso8601(resp[:forecast][1][:time]) - Time.iso8601(resp[:forecast][0][:time])).to eq(10_800)
      expect(request).to have_been_requested.once
    end

    it 'serves fresh cache entries without network requests' do
      Weather.create(location: 'London', data: @data, fetched_at: Time.now)
      get '/weather/London'
      timestamp = resp[:fetched_at]
      get '/weather/London'
      expect(last_response.status).to eq(200)
      expect(resp[:fetched_at]).to eq(timestamp)
      expect(a_request(:get, @url)).not_to have_been_made
    end

    it 'refreshes an expired cache entry without inserting a duplicate' do
      weather = Weather.create(location: 'Paris', data: @data, fetched_at: Time.now - 3601)
      upstream('Paris').to_return(status: 200, body: @data)
      get '/weather/Paris'
      expect(last_response.status).to eq(200)
      expect(Weather.count).to eq(1)
      expect(weather.refresh.fetched_at).to be > Time.now - 10
    end

    it 'maps an unknown location to 404' do
      upstream('Unknown').to_return(status: 404, body: 'upstream private detail')
      get '/weather/Unknown'
      expect(last_response.status).to eq(404)
      expect(last_response.body).not_to include('private detail')
    end

    it 'maps timeouts to a sanitized 502' do
      upstream('London').to_timeout
      get '/weather/London'
      expect(last_response.status).to eq(502)
      expect(last_response.body).not_to include('test-weather-key')
    end

    it 'maps invalid upstream JSON to a sanitized 502' do
      upstream('London').to_return(status: 200, body: 'not json')
      get '/weather/London'
      expect(last_response.status).to eq(502)
    end

    it 'does not cache structurally invalid upstream data' do
      upstream('London').to_return(status: 200, body: '{"list":[{}]}')
      get '/weather/London'
      expect(last_response.status).to eq(502)
      expect(Weather.count).to eq(0)
    end

    it 'lists cached locations with pagination' do
      Weather.create(location: 'London', data: @data, fetched_at: Time.now)
      Weather.create(location: 'Paris', data: @data, fetched_at: Time.now)
      get '/weather', limit: 1
      expect(last_response.status).to eq(200)
      expect(resp.length).to eq(1)
      expect(resp.first[:is_cached]).to eq(true)
    end
  end
end
