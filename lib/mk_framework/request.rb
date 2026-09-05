# frozen_string_literal: true

module MK
  # Enforce the limit even for chunked bodies with no Content-Length header.
  class RequestBoundary
    def initialize(app, settings)
      @app, @settings = app, settings
    end

    def call(env)
      env['mk.request_id'] = SecureRandom.uuid
      if (input = env['rack.input'])
        body = input.read(@settings[:max_body_bytes] + 1)
        if body.bytesize > @settings[:max_body_bytes]
          json = JSON.generate(error: 'Request body too large', request_id: env['mk.request_id'])
          return [413, {'content-type' => 'application/json', 'content-length' => json.bytesize.to_s,
                        'x-request-id' => env['mk.request_id']}, env['REQUEST_METHOD'] == 'HEAD' ? [] : [json]]
        end
        env['rack.input'] = StringIO.new(body)
      end
      status, headers, body = @app.call(env)
      [status, headers.merge('x-request-id' => env['mk.request_id']), body]
    end
  end

  class Input
    def initialize(params)
      @params = params
    end

    def require(name, type: String)
      raise BadRequest, "Missing parameter: #{name}" unless @params.key?(name.to_s)

      cast(name, @params.fetch(name.to_s), type)
    end

    # Only explicitly listed fields reach a model. Unknown fields are ignored.
    def permit(**fields)
      fields.each_with_object({}) do |(name, type), values|
        values[name] = cast(name, @params[name.to_s], type) if @params.key?(name.to_s)
      end
    end

    def integer(name, default:, min: 0, max: nil)
      value = @params.fetch(name.to_s, default)
      valid = value.is_a?(Integer) || (value.is_a?(String) && value.match?(/\A[0-9]+\z/))
      raise BadRequest, "Invalid parameter: #{name}" unless valid

      value = Integer(value)
      raise BadRequest, "Invalid parameter: #{name}" if value < min || (max && value > max)

      value
    end

    private

    def cast(name, value, type)
      if type == :boolean
        return true if [true, 'true', '1'].include?(value)
        return false if [false, 'false', '0'].include?(value)
      elsif Array(type).any? { |klass| klass === value }
        return value
      end
      raise BadRequest, "Invalid parameter: #{name}"
    end
  end

  module RequestPlugin
    module RequestMethods
      EMPTY_PARAMS = {}.freeze
      def path_params = env.fetch('mk.path_params', EMPTY_PARAMS)

      # Compatibility for existing controllers; route identifiers always win.
      def params
        input_params = super
        env['mk.input_params'] = input_params
        input_params.merge(path_params.transform_keys(&:to_s))
      end

      def input
        params
        Input.new(env.fetch('mk.input_params'))
      end

      def page
        settings = roda_class.settings
        {
          limit: input.integer(:limit, default: settings[:page_size], min: 1, max: settings[:max_page_size]),
          offset: input.integer(:offset, default: 0, max: settings[:max_offset])
        }
      end
    end
  end
end
