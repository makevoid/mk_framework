# frozen_string_literal: true

require 'sequel'
require 'json'
require 'roda'
require 'securerandom'
require_relative '../../lib/mk_framework'

# Set up database connection
DB = Sequel.connect('sqlite://ecommerce.db')

# Create products table
DB.create_table? :products do
  primary_key :id
  String :name, null: false
  String :description
  BigDecimal :price, size: [10, 2], null: false
  Integer :stock, default: 0, null: false
  String :sku, unique: true
  String :image_url
  TrueClass :active, default: true
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Create carts table
DB.create_table? :carts do
  primary_key :id
  String :session_id, null: false, unique: true
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Create cart_items table
DB.create_table? :cart_items do
  primary_key :id
  foreign_key :cart_id, :carts, null: false, on_delete: :cascade
  foreign_key :product_id, :products, null: false
  Integer :quantity, null: false, default: 1
  BigDecimal :price, size: [10, 2], null: false
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP

  index [:cart_id, :product_id], unique: true
end

# Create orders table
DB.create_table? :orders do
  primary_key :id
  String :order_number, null: false, unique: true
  foreign_key :cart_id, :carts
  BigDecimal :total, size: [10, 2], null: false
  String :status, default: 'pending'
  String :customer_email, null: false
  String :customer_name, null: false
  String :shipping_address, null: false
  String :payment_method
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
  DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
end

# Require models
require_relative 'models/product'
require_relative 'models/cart'
require_relative 'models/cart_item'
require_relative 'models/order'

# Create application instance
class EcommerceApp < MK::Application
  register_cors_domain 'http://localhost:3001'

  register_nested_resource('carts', 'products')
end
