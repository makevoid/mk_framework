# frozen_string_literal: true

class Order < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps
  
  many_to_one :user
  one_to_many :order_items
  
  VALID_STATUSES = %w[pending confirmed processing shipped delivered cancelled].freeze
  
  def validate
    super
    validates_presence [:user_id, :total_amount, :shipping_address, :status]
    validates_includes VALID_STATUSES, :status
    validates_numeric :total_amount
    validates_operator :>=, 0, :total_amount
  end
  
  def items_count
    order_items.sum(:quantity)
  end
  
  def can_cancel?
    %w[pending confirmed].include?(status)
  end
  
  def can_ship?
    status == 'confirmed'
  end
  
  def formatted_total
    "$%.2f" % total_amount
  end
end