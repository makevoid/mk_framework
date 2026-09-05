# frozen_string_literal: true

module SampleApp5
  class Card < Sequel::Model(DB[:cards])
    plugin :validation_helpers
    plugin :defaults_setter
    plugin :timestamps, update_on_create: true
    one_to_many :comments, class: 'SampleApp5::Comment'

    def validate
      super
      validates_presence [:title]
      validates_max_length 100, :title
      validates_includes ['Todo', 'In Progress', 'Done'], :status
    end

    def self.public_attributes_list
      [:id, :title, :description, :status, :created_at, :updated_at]
    end
  end
end
