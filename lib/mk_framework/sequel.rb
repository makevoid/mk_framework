# frozen_string_literal: true

require 'sequel'
require_relative '../mk_framework'

module MK
  # Optional, explicit persistence helpers. Handlers never write to the database.
  module Persistence
    def persist(record)
      record.save || raise(ValidationError.new(details: record.errors))
    rescue Sequel::ValidationFailed => error
      raise ValidationError.new(details: error.model.errors)
    rescue Sequel::UniqueConstraintViolation, Sequel::ForeignKeyConstraintViolation, Sequel::HookFailed
      raise Conflict
    end

    def destroy(record)
      record.destroy || raise(Conflict, 'Resource could not be deleted')
    rescue Sequel::HookFailed, Sequel::ForeignKeyConstraintViolation
      raise Conflict, 'Resource could not be deleted'
    end

    def paginate(dataset, request, order: :id)
      page = request.page
      dataset.order(order).limit(page[:limit], page[:offset]).all
    end
  end
end
