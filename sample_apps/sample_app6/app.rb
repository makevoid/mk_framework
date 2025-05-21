# frozen_string_literal: true

require 'sequel'
require 'json'
require 'roda'
require 'net/http'
require 'uri'
require 'date'
require_relative '../../lib/mk_framework'

# Set up database connection
DB = Sequel.connect('sqlite://weather.db')

# Create weather table if it doesn't exist
DB.create_table? :weathers do
  primary_key :id
  String :location, null: false
  String :data, text: true
  DateTime :fetched_at, default: Sequel::CURRENT_TIMESTAMP
  index :location, unique: true
end

# Require models
require_relative 'models/weather'

# Create application instance
class WeatherApp < MK::Application
  register_cors_domain 'https://kzmq95efeylx3d3m1i5y.lite.vusercontent.net'

  def self.api_key
    @api_key ||= begin
      path = File.expand_path('~/.openweathermap_api_key')
      File.read(path).strip
    rescue Errno::ENOENT
      puts "ERROR: OpenWeatherMap API key file not found at #{path}"
      nil
    end
  end
end
