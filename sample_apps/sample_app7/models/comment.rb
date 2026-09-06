# frozen_string_literal: true

module SampleApp7
  class Comment < Sequel::Model(DB[:comments])
    plugin :validation_helpers
    plugin :timestamps, update_on_create: true
    many_to_one :card, class: 'SampleApp7::Card'

    def validate
      super
      validates_presence [:content, :card_id]
      validates_max_length 1000, :content
      validates_max_length 100, :author if author
    end

    def self.public_attributes_list
      [:id, :card_id, :content, :author, :created_at, :updated_at]
    end
  end
end
