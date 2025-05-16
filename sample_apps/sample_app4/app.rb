# frozen_string_literal: true

require 'sequel'
require 'json'
require 'roda'
require_relative '../../lib/mk_framework'

# Set up database connection
DB = Sequel.connect('sqlite://kanban.db')

# Drop existing tables to rebuild schema
DB.drop_table?(:comments) if DB.table_exists?(:comments)
DB.drop_table?(:cards) if DB.table_exists?(:cards)

# Create cards table
DB.create_table :cards do
  primary_key :id
  String :title, null: false
  String :description, text: true
  String :status, null: false, default: 'todo'
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Create comments table
DB.create_table :comments do
  primary_key :id
  foreign_key :card_id, :cards, on_delete: :cascade, null: false
  String :content, null: false, text: true
  String :author
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Require models
require_relative 'models/card'
require_relative 'models/comment'

# Create application instance
class KanbanApp < MK::Application
  # Register comments as a nested resource of cards
  register_nested_resource 'cards', 'comments'
end