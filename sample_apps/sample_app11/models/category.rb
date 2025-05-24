# frozen_string_literal: true

class Category < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps
  
  one_to_many :products
  
  def validate
    super
    validates_presence [:name]
    validates_unique :name
    validates_max_length 100, :name
    validates_max_length 500, :description if description
  end
  
  def products_count
    products.count
  end
  
  def active_products_count
    products.where(active: true).count
  end
end