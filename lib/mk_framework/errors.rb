# frozen_string_literal: true

module MK
  class ConfigurationError < StandardError; end

  class Error < StandardError
    STATUS = 500
    MESSAGE = 'Server error'
    attr_reader :details

    def initialize(message = self.class::MESSAGE, details: nil)
      super(message)
      @details = details
    end

    def status = self.class::STATUS
  end

  class BadRequest < Error
    STATUS = 400
    MESSAGE = 'Bad request'
  end

  class Unauthorized < Error
    STATUS = 401
    MESSAGE = 'Unauthorized'
  end

  class Forbidden < Error
    STATUS = 403
    MESSAGE = 'Forbidden'
  end

  class NotFound < Error
    STATUS = 404
    MESSAGE = 'Not Found'
  end

  class Conflict < Error
    STATUS = 409
    MESSAGE = 'Conflict'
  end

  class ValidationError < Error
    STATUS = 422
    MESSAGE = 'Validation failed'
  end

  class BadGateway < Error
    STATUS = 502
    MESSAGE = 'Upstream service unavailable'
  end

  module ErrorDetails
    FILTER_KEYS = %w[password secret token authorization cookie api_key apikey credential].freeze

    def self.filter(value, keys = FILTER_KEYS, depth = 0)
      return '[TRUNCATED]' if depth > 10

      case value
      when Hash
        value.to_h do |key, item|
          sensitive = keys.any? { |pattern| key.to_s.downcase.include?(pattern.to_s.downcase) }
          [key, sensitive ? '[FILTERED]' : filter(item, keys, depth + 1)]
        end
      when Array
        value.map { |item| filter(item, keys, depth + 1) }
      else
        value
      end
    end

    # Never parse input while reporting an error: parsing may be what failed.
    # SQL exception messages can contain secrets; omit them in production.
    def self.details(error, request, settings)
      details = {
        request_id: request.env['mk.request_id'],
        method: request.request_method,
        path: request.path,
        error_class: error.class.name,
        params: filter(request.env.fetch('mk.input_params', {}), settings[:filter_parameters]),
        backtrace: Array(error.backtrace).first(30)
      }
      details[:message] = error.message if settings[:environment] == 'development'
      details
    end
  end
end
