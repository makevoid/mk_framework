# frozen_string_literal: true

class Event < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence [:title, :start_time]
    validates_max_length 100, :title
    validates_max_length 500, :description
  end
end