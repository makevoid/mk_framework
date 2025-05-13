# frozen_string_literal: true

require 'sequel'
require 'json'
require 'roda'
require_relative '../../lib/mk_framework'

# Set up database connection
DB = Sequel.connect('sqlite://todos.db')

# Create todos table if it doesn't exist
DB.create_table? :todos do
  primary_key :id
  String :title, null: false
  String :description
  TrueClass :completed, default: false
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Require models
require_relative 'models/todo'

# Create application instance
class TodoApp < MK::Application
  def initialize
    super('routes') # Path to the routes directory
  end
end
