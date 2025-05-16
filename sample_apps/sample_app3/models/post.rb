# frozen_string_literal: true

class Post < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence [:title]
    validates_max_length 100, :title
  end
end