# frozen_string_literal: true

class Comment < Sequel::Model
  plugin :validation_helpers
  
  many_to_one :post
  
  def validate
    super
    validates_presence [:content, :post_id]
    validates_max_length 1000, :content
    validates_max_length 100, :author if author
  end
end