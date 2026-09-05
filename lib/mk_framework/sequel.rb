# frozen_string_literal: true

require 'sequel'
require_relative '../mk_framework'

module MK
  # Shared by automatic resource actions and explicit application transactions.
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

  class Application
    include Persistence

    private

    def prepare_result(value, action:)
      if value.is_a?(Sequel::Model)
        case action
        when :create, :update then persist(value)
        when :delete then destroy(value)
        end
      end
      raw_result(value)
    end

    # Materialize all data before the handler. Associations must be selected by
    # the controller; inspecting a record's values never lazy-loads them.
    def raw_result(value)
      case value
      when Sequel::Model then raw_result(value.values)
      when Sequel::Dataset then raw_result(value.all)
      when Array then value.map { |item| raw_result(item) }
      when Hash then value.transform_values { |item| raw_result(item) }
      else value
      end
    end
  end
end
