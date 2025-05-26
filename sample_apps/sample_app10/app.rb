# frozen_string_literal: true

require 'sequel'
require 'json'
require 'roda'
require 'bcrypt'
require_relative '../../lib/mk_framework'

# Set up database connection
DB = Sequel.connect('sqlite://project_management.db')

# Create tables if they don't exist
DB.create_table? :users do
  primary_key :id
  String :name, null: false
  String :email, null: false, unique: true
  String :password_hash, null: false
  String :role, default: 'member' # admin, manager, member
  TrueClass :active, default: true
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

DB.create_table? :projects do
  primary_key :id
  String :name, null: false
  String :description
  String :status, default: 'active' # active, completed, archived, on_hold
  Date :start_date
  Date :end_date
  Integer :owner_id, null: false
  TrueClass :archived, default: false
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
  
  foreign_key [:owner_id], :users
  index :status
  index :archived
end

DB.create_table? :tasks do
  primary_key :id
  String :title, null: false
  String :description
  String :status, default: 'todo' # todo, in_progress, review, done
  String :priority, default: 'medium' # low, medium, high, critical
  Integer :project_id, null: false
  Integer :assigned_to_id
  Integer :created_by_id, null: false
  Date :due_date
  Integer :estimated_hours
  Integer :actual_hours
  DateTime :completed_at
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
  
  foreign_key [:project_id], :projects
  foreign_key [:assigned_to_id], :users
  foreign_key [:created_by_id], :users
  index :status
  index :priority
  index :project_id
end

DB.create_table? :comments do
  primary_key :id
  String :content, null: false, text: true
  Integer :task_id, null: false
  Integer :user_id, null: false
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
  
  foreign_key [:task_id], :tasks
  foreign_key [:user_id], :users
  index :task_id
end

# Require models
require_relative 'models/user'
require_relative 'models/project'
require_relative 'models/task'
require_relative 'models/comment'

# Create application instance
class ProjectManagementApp < MK::Application
  # No need to override initialize - the parent class handles everything
  
  # FIXME - register routes
end
