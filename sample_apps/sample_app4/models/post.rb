# frozen_string_literal: true

class Card < Sequel::Model
  plugin :validation_helpers
  
  one_to_many :comments, :on_delete => :cascade
  
  def validate
    super
    validates_presence [:title]
    validates_max_length 100, :title
    validates_includes ['Todo', 'In Progress', 'Done'], :status if status
  end
  
  def before_destroy
    Comment.where(card_id: id).delete
    super
  end
end