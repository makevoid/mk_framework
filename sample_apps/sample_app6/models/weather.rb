# frozen_string_literal: true

class Weather < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence [:location]
    validates_max_length 100, :location
  end
end