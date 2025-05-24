# frozen_string_literal: true

require 'sequel'
require 'json'
require 'roda'
require 'bcrypt'
require_relative '../../lib/mk_framework'

# Set up database connection
DB = Sequel.connect('sqlite://ecommerce.db')

# Create users table
DB.create_table? :users do
  primary_key :id
  String :email, null: false, unique: true
  String :password_hash, null: false
  String :first_name, null: false
  String :last_name, null: false
  String :phone
  String :address, text: true
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Create categories table
DB.create_table? :categories do
  primary_key :id
  String :name, null: false, unique: true
  String :description, text: true
  TrueClass :active, default: true
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Create products table
DB.create_table? :products do
  primary_key :id
  foreign_key :category_id, :categories, null: false
  String :name, null: false
  String :description, text: true
  BigDecimal :price, size: [10, 2], null: false
  Integer :stock_quantity, default: 0
  String :sku, unique: true
  TrueClass :active, default: true
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Create cart_items table
DB.create_table? :cart_items do
  primary_key :id
  foreign_key :user_id, :users, null: false
  foreign_key :product_id, :products, null: false
  Integer :quantity, default: 1
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP

  unique [:user_id, :product_id]
end

# Create orders table
DB.create_table? :orders do
  primary_key :id
  foreign_key :user_id, :users, null: false
  String :status, default: 'pending'
  BigDecimal :total_amount, size: [10, 2], null: false
  String :shipping_address, text: true, null: false
  String :notes, text: true
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Create order_items table
DB.create_table? :order_items do
  primary_key :id
  foreign_key :order_id, :orders, on_delete: :cascade, null: false
  foreign_key :product_id, :products, null: false
  Integer :quantity, null: false
  BigDecimal :unit_price, size: [10, 2], null: false
  BigDecimal :total_price, size: [10, 2], null: false
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
end

# Require models
require_relative 'models/user'
require_relative 'models/category'
require_relative 'models/product'
require_relative 'models/cart_item'
require_relative 'models/order'
require_relative 'models/order_item'

# Create application instance
class EcommerceApp < MK::Application
  register_cors_domain 'http://localhost:3000'
  register_cors_domain 'http://localhost:3001'

  # Register cart_items as nested resource of users
  register_nested_resource 'users', 'cart_items'

  # Register order_items as nested resource of orders
  register_nested_resource 'orders', 'order_items'
end
