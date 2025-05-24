# frozen_string_literal: true

require 'sequel'
require 'json'
require 'roda'
require_relative '../../lib/mk_framework'

# Set up database connection
DB = Sequel.connect('sqlite://calendar.db')

# Create todos table if it doesn't exist
DB.create_table? :todos do
  primary_key :id
  String :title, null: false
  String :description
  TrueClass :completed, default: false
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Create events table if it doesn't exist
DB.create_table? :events do
  primary_key :id
  String :title, null: false
  String :description
  DateTime :start_time, null: false
  DateTime :end_time
  String :location
  TrueClass :all_day, default: false
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Require models
require_relative 'models/todo'
require_relative 'models/event'

# Create application instance
class CalendarApp < MK::Application
  register_cors_domain 'http://localhost:3001'
  # register_cors_domain 'https://v0-create-calendar-with-api.vercel.app'
end
