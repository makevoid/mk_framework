# frozen_string_literal: true

class Post < Sequel::Model
  plugin :validation_helpers
  
  one_to_many :comments, :on_delete => :cascade
  
  def validate
    super
    validates_presence [:title]
    validates_max_length 100, :title
  end
  
  def before_destroy
    Comment.where(post_id: id).delete
    super
  end
end