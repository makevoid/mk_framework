# frozen_string_literal: true

module SampleApp4
  class Post < Sequel::Model(DB[:posts])
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true
    one_to_many :comments, class: 'SampleApp4::Comment'

    def validate
      super
      validates_presence [:title]
      validates_max_length 100, :title
    end

    def public_attributes
      values.slice(:id, :title, :description, :created_at, :updated_at)
    end
  end
end
