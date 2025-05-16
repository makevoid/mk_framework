# frozen_string_literal: true

require 'sequel'
require 'json'
require 'roda'
require_relative '../../lib/mk_framework'

# Set up database connection
DB = Sequel.connect('sqlite://blog.db')

# Drop existing tables to rebuild schema
DB.drop_table?(:comments) if DB.table_exists?(:comments)
DB.drop_table?(:posts) if DB.table_exists?(:posts)

# Create posts table
DB.create_table :posts do
  primary_key :id
  String :title, null: false
  String :description, text: true
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Create comments table
DB.create_table :comments do
  primary_key :id
  foreign_key :post_id, :posts, on_delete: :cascade, null: false
  String :content, null: false, text: true
  String :author
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Require models
require_relative 'models/post'
require_relative 'models/comment'

# Create application instance
class BlogApp < MK::Application
  # Register comments as a nested resource of posts
  register_nested_resource 'posts', 'comments'
end
