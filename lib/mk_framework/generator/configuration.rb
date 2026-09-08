# frozen_string_literal: true

module MK
  module Generator
    class InvalidInput < ArgumentError; end

    class Configuration
      TYPES = {
        'string' => ['String', 'String', 'Example'],
        'text' => ['String', 'String', 'Example text'],
        'integer' => ['Integer', 'Integer', 1],
        'float' => ['Float', '[Integer, Float]', 1.5],
        'boolean' => ['TrueClass', ':boolean', false],
        'date' => ['Date', 'String', '2026-01-01'],
        'datetime' => ['DateTime', 'String', '2026-01-01T12:00:00Z']
      }.transform_values(&:freeze).freeze
      KEYWORDS = %w[alias and begin break case class def defined do else elsif end ensure false
                    for if in module next nil not or redo rescue retry return self super then
                    true undef unless until when while yield __FILE__ __LINE__ __ENCODING__].freeze
      RESERVED_FIELDS = (KEYWORDS + %w[id created_at updated_at save save_changes destroy delete
        values errors valid validate set update refresh new db dataset model table_name columns
        pk pk_hash this associations changed_columns raise fail send public_send method methods
        object_id instance_eval instance_exec initialize hash eql equal freeze frozen inspect
        to_s to_json to_hash to_a tap then itself dup clone before_validation after_validation
        before_save after_save before_create after_create before_update after_update
        before_destroy after_destroy around_validation around_save around_create around_update
        around_destroy set_fields update_fields validate_save skip_validation_on_next_save
        get_column_value set_column_value raise_on_save_failure use_transactions require_modification]).freeze
      RESERVED_MODELS = %w[app controller handler database tasks root db].freeze
      RESERVED_CONSTANTS = %w[Object BasicObject Class Module Kernel String Integer Float Numeric
        TrueClass FalseClass NilClass Array Hash Symbol Date DateTime Time File Dir Io Process
        Thread Exception StandardError Sequel Roda Rack Rspec Rake Json Logger Erb FileUtils].freeze

      attr_reader :app_name, :model_name, :resource, :fields

      def self.identifier!(value, label: 'Name')
        unless value.is_a?(String) && value.match?(/\A[a-z][a-z0-9]*(?:_[a-z0-9]+)*\z/) && !KEYWORDS.include?(value)
          raise InvalidInput, "#{label} must be a lowercase Ruby name, such as blog or blog_post."
        end
        value
      end

      def self.model_name!(value)
        identifier!(value, label: 'Model name')
        if RESERVED_MODELS.include?(value) || RESERVED_CONSTANTS.include?(camelize(value))
          raise InvalidInput, 'That model name is reserved by Ruby or the application.'
        end
        value
      end

      def self.app_name!(value)
        identifier!(value, label: 'App name')
        raise InvalidInput, 'That app name conflicts with a Ruby or library constant.' if RESERVED_CONSTANTS.include?(camelize(value))
        value
      end

      def self.field!(name, type)
        identifier!(name, label: 'Field name')
        raise InvalidInput, "Field #{name} is reserved; id and timestamps are generated automatically." if RESERVED_FIELDS.include?(name)
        raise InvalidInput, "Unknown field type: #{type}." unless TYPES.key?(type)
        {name: name.dup.freeze, type: type.dup.freeze}.freeze
      end

      def self.camelize(name) = name.split('_').map(&:capitalize).join

      def initialize(app_name:, model_name:, resource:, fields:)
        @app_name = self.class.app_name!(app_name).dup.freeze
        @model_name = self.class.model_name!(model_name).dup.freeze
        @resource = self.class.identifier!(resource, label: 'Resource name').dup.freeze
        if self.class.camelize(resource) + 'CreateController' == model_class ||
           self.class.camelize(resource) + 'CreateHandler' == model_class
          raise InvalidInput, 'Model name conflicts with a generated action class.'
        end
        raise InvalidInput, 'Add at least one field.' if fields.empty?
        @fields = fields.map { |field| self.class.field!(field.fetch(:name), field.fetch(:type)) }.freeze
        raise InvalidInput, 'Field names must be unique.' unless @fields.map { |f| f[:name] }.uniq.length == @fields.length
        freeze
      end

      def namespace = self.class.camelize(app_name)
      def model_class = self.class.camelize(model_name)
      def action_prefix = self.class.camelize(resource)
      def field_names = fields.map { |field| field[:name] }
      def example = fields.to_h { |field| [field[:name], TYPES.fetch(field[:type])[2]] }
    end
  end
end
