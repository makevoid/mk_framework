# frozen_string_literal: true

require 'sequel'
require 'json'
require 'roda'
require_relative '../../lib/mk_framework'

# Set up database connection
DB = Sequel.connect('sqlite://blog.db')

# Create posts table if it doesn't exist
DB.create_table? :posts do
  primary_key :id
  String :title, null: false
  String :description, text: true
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Require models
require_relative 'models/post'

# Create application instance
class BlogApp < MK::Application
  # No need to override initialize - the parent class handles everything
end
