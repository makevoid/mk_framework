# frozen_string_literal: true

module SampleApp7
  class Card < Sequel::Model(DB[:cards])
    STATUSES = ['Todo', 'In Progress', 'Done'].freeze
    PRIORITIES = %w[low normal high urgent].freeze

    plugin :validation_helpers
    plugin :defaults_setter
    plugin :timestamps, update_on_create: true
    one_to_many :comments, class: 'SampleApp7::Comment'

    def validate
      super
      validates_presence [:title]
      validates_max_length 100, :title
      validates_includes STATUSES, :status
      validates_includes PRIORITIES, :priority
      validates_max_length 10_000, :description if description
      validates_max_length 100, :assignee if assignee
      validates_includes [true, false], :archived
      if archived
        errors.add(:position, 'must be empty for archived cards') unless position.nil?
      elsif !position.is_a?(Integer) || position.negative?
        errors.add(:position, 'must be a nonnegative integer')
      end
    end

    def self.public_attributes_list
      [:id, :title, :description, :status, :position, :priority, :assignee,
       :due_date, :archived, :created_at, :updated_at]
    end
  end
end
