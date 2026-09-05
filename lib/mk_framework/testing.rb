# frozen_string_literal: true

require 'json'
require 'rack/test'

module MK
  module Framework
    module Spec
      class StrictHash < Hash
        def [](key) = fetch(key)
      end

      include Rack::Test::Methods

      # Parsing on demand keeps this correct for every Rack::Test request method,
      # including custom_request and follow_redirect!, with no monkey patches.
      def resp
        body = last_response.body
        body.empty? ? StrictHash.new : symbolize(JSON.parse(body))
      end

      private

      def symbolize(value)
        case value
        when Hash
          value.each_with_object(StrictHash.new) { |(key, item), result| result[key.to_sym] = symbolize(item) }
        when Array
          value.map { |item| symbolize(item) }
        else
          value
        end
      end
    end
  end
end
