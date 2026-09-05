# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
require 'mk_framework/sequel'
require 'rack/mock'
require 'rack/lint'
require 'tmpdir'
require 'rspec'

module FrameworkHelpers
  def action(namespace, resource, action, &controller_block)
    controller = Class.new(MK::Controller)
    controller.route(&controller_block)
    handler = Class.new(MK::Handler)
    handler.handler { |_r| model }
    namespace.const_set("#{MK::Routes.camelize(resource)}#{MK::Routes.camelize(action)}Controller", controller)
    namespace.const_set("#{MK::Routes.camelize(resource)}#{MK::Routes.camelize(action)}Handler", handler)
    [controller, handler]
  end

  def build_app(namespace: Module.new, routes: nil, custom: nil, hook: nil, **settings)
    klass = Class.new(MK::Application)
    klass.configure(root: __dir__, routes_path: 'missing_routes', namespace: namespace,
                    environment: 'production', logger: Logger.new(StringIO.new), **settings)
    klass.resource_routes(&routes) if routes
    klass.route(&custom) if custom
    klass.before_request(&hook) if hook
    klass.boot!
    klass
  end

  def request(app, verb, path, input: nil, **env)
    Rack::MockRequest.new(Rack::Lint.new(app.app)).request(verb, path, input: input,
      'CONTENT_TYPE' => 'application/json', **env)
  end

  def body(response) = JSON.parse(response.body)
end

RSpec.configure do |config|
  config.include FrameworkHelpers
  config.order = :random
  config.disable_monkey_patching!
end
