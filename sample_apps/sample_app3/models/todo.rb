# frozen_string_literal: true

module SampleApp3
  class Todo < Sequel::Model(DB[:todos])
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true

    def validate
      super
      validates_presence [:title]
      validates_max_length 100, :title
    end

    def public_attributes
      values.slice(:id, :title, :description, :completed, :created_at, :updated_at)
    end
  end
end
