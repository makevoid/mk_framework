# frozen_string_literal: true

require 'strscan'

module MK
  module Generator
    module Naming
      IRREGULAR = {'person' => 'people', 'child' => 'children', 'man' => 'men', 'woman' => 'women'}.freeze

      def self.singular(name)
        return IRREGULAR.key(name) if IRREGULAR.value?(name)
        return "#{name[0...-3]}y" if name.end_with?('ies')
        return name[0...-2] if name.match?(/(?:sses|shes|ches|xes|zes|statuses)\z/)
        name.end_with?('s') && !name.end_with?('ss', 'us') ? name[0...-1] : name
      end

      def self.plural(name)
        return IRREGULAR.fetch(name) if IRREGULAR.key?(name)
        return "#{name[0...-1]}ies" if name.match?(/[^aeiou]y\z/)
        name.match?(/(?:s|sh|ch|x|z)\z/) ? "#{name}es" : "#{name}s"
      end
    end

    # This is a small data grammar, never Ruby evaluation or shell input.
    class Options
      def self.parse(source)
        new(source).parse
      end

      def initialize(source)
        @scanner = StringScanner.new(source)
      end

      def parse
        options = {}
        loop do
          key = identifier
          raise InvalidInput, "Unknown option: #{key}." unless %w[app_name model_name resource_name fields].include?(key)
          raise InvalidInput, "Duplicate option: #{key}." if options.key?(key)
          token(':')
          options[key] = key == 'fields' ? fields : identifier
          whitespace
          break if @scanner.eos?
          token(',')
        end
        %w[app_name model_name fields].each do |key|
          raise InvalidInput, "Missing option: #{key}." unless options.key?(key)
        end
        model = Naming.singular(options.fetch('model_name'))
        Configuration.new(app_name: options.fetch('app_name'), model_name: model,
          resource: options.fetch('resource_name') { Naming.plural(model) }, fields: options.fetch('fields'))
      end

      private

      def fields
        token('[')
        result = []
        whitespace
        unless @scanner.peek(1) == ']'
          loop do
            name = identifier
            token(':')
            result << {name: name, type: identifier}
            whitespace
            break if @scanner.peek(1) == ']'
            token(',')
          end
        end
        token(']')
        result
      end

      def whitespace = @scanner.skip(/\s*/)

      def identifier
        whitespace
        @scanner.scan(/[a-z][a-z0-9_]*/) || invalid!
      end

      def token(value)
        whitespace
        invalid! unless @scanner.scan(/#{Regexp.escape(value)}/)
      end

      def invalid!
        raise InvalidInput, 'Invalid --cli syntax. Use app_name:blog, model_name:posts, fields:[title:string, contents:text].'
      end
    end
  end
end
