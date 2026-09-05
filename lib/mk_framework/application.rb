# frozen_string_literal: true

module MK
  class Application < Roda
    plugin :all_verbs
    plugin :json
    plugin :halt
    plugin :head
    plugin :json_parser,
           parser: ->(body) { value = JSON.parse(body); raise BadRequest unless value.is_a?(Hash); value },
           error_handler: ->(_request) { raise BadRequest, 'Expected a valid JSON object' }
    plugin RequestPlugin
    plugin :error_handler do |error|
      public_error = error.is_a?(MK::Error)
      response.status = public_error ? error.status : 500
      details = ErrorDetails.details(error, request, self.class.settings)
      begin
        logger.error(JSON.generate(details)) unless public_error
      rescue StandardError
        # A failed log sink must not break the error response.
      end
      body = {error: public_error ? error.message : 'Server error', request_id: request.env['mk.request_id']}
      body[:details] = ErrorDetails.filter(error.details, self.class.settings[:filter_parameters]) if public_error && error.details
      body[:debug] = details if self.class.settings[:environment] == 'development'
      body
    end

    class << self
      attr_reader :settings, :router

      def inherited(subclass)
        super
        defaults = @settings || {
          environment: ENV.fetch('RACK_ENV', 'production'), root: nil, namespace: nil,
          routes_path: 'routes', legacy_post_routes: true, max_body_bytes: 1_048_576,
          page_size: 25, max_page_size: 100, max_offset: 10_000,
          filter_parameters: ErrorDetails::FILTER_KEYS, logger: Logger.new($stdout)
        }
        subclass.instance_variable_set(:@settings, defaults.dup)
        subclass.instance_variable_set(:@route_definitions, @route_definitions)
        subclass.instance_variable_set(:@request_hooks, Array(@request_hooks).dup)
        subclass.instance_variable_set(:@booted, false)
      end

      def configure(**options)
        raise ConfigurationError, 'Configure the application before boot!' if @booted
        unknown = options.keys - @settings.keys
        raise ConfigurationError, "Unknown settings: #{unknown.join(', ')}" unless unknown.empty?

        @settings.merge!(options)
      end

      def setup_logger(destination = $stdout)
        configure(logger: Logger.new(destination))
        logger
      end

      def logger = settings.fetch(:logger)

      def resource_routes(&block)
        raise ConfigurationError, 'Define resources before boot!' if @booted

        @route_definitions = block
      end

      # Runs for generated and ordinary Roda routes, including mounted apps.
      def before_request(&block)
        raise ConfigurationError, 'Define hooks before boot!' if @booted

        @request_hooks << block
      end

      def request_hooks = @request_hooks

      def boot!
        return self if @booted
        raise ConfigurationError, 'Set an absolute application root with configure(root: __dir__, namespace: MyApp)' unless settings[:root] && File.absolute_path(settings[:root]) == settings[:root]
        raise ConfigurationError, 'Set namespace to the module containing your controllers and handlers' unless settings[:namespace].is_a?(Module)
        %i[max_body_bytes page_size max_page_size max_offset].each do |key|
          raise ConfigurationError, "#{key} must be a positive integer" unless settings[key].is_a?(Integer) && settings[key].positive?
        end
        raise ConfigurationError, 'page_size exceeds max_page_size' if settings[:page_size] > settings[:max_page_size]

        routes_path = File.expand_path(settings[:routes_path], settings[:root])
        Dir.glob(File.join(routes_path, '**', '*.rb')).sort.each { |file| require file }
        definitions = Routes.new(namespace: settings[:namespace], legacy: settings[:legacy_post_routes])
        if @route_definitions
          definitions.instance_eval(&@route_definitions)
        else
          Dir.glob(File.join(routes_path, '*')).sort.select { |path| File.directory?(path) }.each do |path|
            actions = Dir.glob(File.join(path, 'controllers', '*.rb')).map { |file| File.basename(file, '.rb').to_sym }
            actions.select! { |action| Routes::ACTIONS.key?(action) }
            definitions.resources(File.basename(path), only: actions)
          end
        end
        @router = Router.new(definitions.endpoints)
        @settings[:filter_parameters] = (ErrorDetails::FILTER_KEYS + Array(settings[:filter_parameters])).map { |key| key.to_s.freeze }.uniq.freeze
        @settings.freeze
        @request_hooks.freeze
        custom_route = route_block
        use RequestBoundary, settings
        route do |r|
          self.class.request_hooks.each { |hook| instance_exec(r, &hook) }
          if custom_route
            result = instance_exec(r, &custom_route)
            r.halt(response.status || 200, result) unless result.nil?
          end
          r.root { {message: 'Welcome to MK Framework'} }
          self.class.router.call(r, self)
        end
        @booted = true
        freeze
      end

      def app
        raise ConfigurationError, 'Call boot! after defining your application' unless @booted

        super
      end

      def route_table
        router.endpoints.map { |entry| "#{entry[:verb].ljust(6)} /#{entry[:path].map { |part| part.is_a?(Symbol) ? ":#{part}" : part }.join('/')} -> #{entry[:controller]} / #{entry[:handler]}" }
      end
    end

    def logger = self.class.logger

    def dispatch(endpoint, request)
      value = endpoint[:controller].new.execute(request)
      raise NotFound, "#{endpoint[:label]} not found" if value.nil?

      result = endpoint[:handler].new(value).execute(request)
      unless result.is_a?(Hash) || result.is_a?(Array)
        raise ConfigurationError, 'Handlers must return a Hash or Array, or halt with an explicit response'
      end
      result
    end
  end
end
