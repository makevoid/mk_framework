# frozen_string_literal: true

require 'roda'
require 'sequel'
require 'logger'
require 'json'
require 'yaml'
require 'fileutils'

# TODO: REFACTOR THIS
def singularize(str)
  return str[0..-2] if str.end_with?('s')
  str
end

module MK
  # Base MK application
  class Application < Roda
    plugin :all_verbs
    plugin :json
    plugin :json_parser
    plugin :halt
    plugin :not_found
    plugin :error_handler do |e|
      # Create a detailed error object
      error_details = {
        request_info: {
          path: request.path,
          method: request.request_method,
          params: request.params.reject { |k, _| k.to_s.include?('password') }, # Sanitize sensitive data
          message: e.message,
        },
        trace: {
          relevant: e.backtrace.reject { |line| line.include?("ruby_executable_hooks") || line.include?('forwardable') || line.include?('roda') || line.include?('rack-test') || line.include?('rspec')  }
        }
      }

      # Log the detailed error
      if defined?(logger) && logger.respond_to?(:error)
        logger.error "ERROR: #{e.class.name}"
        logger.error e.message
        logger.error "Stacktrace and Info:"
        logger.error JSON.pretty_generate error_details
      else
        puts "ERROR: #{e.class.name}"
        puts e.message
        puts "Stacktrace and Info:"
        puts JSON.pretty_generate error_details
      end

      # In development mode, return the detailed error
      if ENV['RACK_ENV'] == 'development'
        response.status = case e
                          when Sequel::NoMatchingRow, Sequel::UniqueConstraintViolation
                            400
                          when Sequel::ValidationFailed
                            422
                          else
                            500
                          end
        error_details
      else
        # In production, return a sanitized error
        response.status = 500
        { error: "Server error", message: "An unexpected error occurred" }.to_json
      end
    end

    not_found do
      path = self.request.path
      path_split = path.split "/"
      resource = path_split[1]
      if resource && !resource.empty?
        resource_name = singularize resource.capitalize
        { error: "#{resource_name} not found" }
      else
        { error: "Not Found" }
      end
    end

    # Class attribute to store routes path
    class << self
      attr_accessor :routes_path
      attr_accessor :nested_resources
    end

    # load routes when the MK Framework application is inherited
    def self.inherited(subclass)
      super
      subclass.routes_path = 'routes'
      subclass.nested_resources = {}

      # Set up the default route block for the application
      subclass.route do |r|
        # Default root route
        r.root do
          { message: "Welcome to MK Framework" }
        end
      end

      # Load the routes for this application class
      subclass.load_routes
    end

    # Set up a custom logger
    def self.setup_logger(log_path = nil)
      log_path ||= ENV['RACK_ENV'] == 'test' ? StringIO.new : 'log/mk_framework.log'
      log_dir = File.dirname(log_path) unless log_path.is_a?(StringIO)
      FileUtils.mkdir_p(log_dir) if log_dir && !File.directory?(log_dir)

      logger = Logger.new(log_path)
      logger.formatter = proc do |severity, datetime, progname, msg|
        formatted_datetime = datetime.strftime("%Y-%m-%d %H:%M:%S.%L")
        "[#{formatted_datetime}] #{severity}: #{msg}\n"
      end

      define_singleton_method(:logger) { logger }
      logger
    end

    # Class method to load routes based on the directory structure
    def self.load_routes
      return unless routes_path

      Dir.glob(File.join(routes_path, '*')).each do |resource_dir|
        next unless File.directory?(resource_dir)

        resource_name = File.basename(resource_dir)
        register_resource_routes(resource_name)
      end
    end

    ROUTES_MAIN = -> (controller_name:, handler_name:, r:) {
      begin
        resource_name = singularize controller_name.split(/Index|Show|Update|Delete|Create/).first
        if Object.const_defined?(controller_name) && Object.const_defined?(handler_name)
          controller = Object.const_get(controller_name).new
          result = controller.execute(r)
          if result.nil?
            r.halt 404, { error: "#{resource_name} not found" }
          end
          handler = Object.const_get(handler_name).new(result)
          handler.execute(r)
        else
          r.halt 404, { error: "#{resource_name} not found" }
        end
      rescue => e
        # Add contextual information to the exception
        e.define_singleton_method(:context) do
          {
            controller: controller_name,
            handler: handler_name,
            params: r.params.reject { |k, _| k.to_s.include?('password') }
          }
        end
        raise e  # Re-raise for the error_handler plugin to catch
      end
    }

    ROUTES_NESTED = -> (nested_resources:, resource_name:, id:, r:) {
      if nested_resources[resource_name] && !nested_resources[resource_name].empty?
        nested_resources[resource_name].each do |nested_resource|
          r.on nested_resource do
            # GET /resource/:id/nested_resource - Index of nested resources
            r.is do
              r.get do
                controller_name = "#{nested_resource.capitalize}IndexController"
                handler_name = "#{nested_resource.capitalize}IndexHandler"
                param_name = "#{singularize(resource_name)}_id"
                r.params[param_name] = id

                ROUTES_MAIN.(controller_name: controller_name, handler_name: handler_name, r: r)
              end

              # POST /resource/:id/nested_resource - Create nested resource
              r.post do
                controller_name = "#{nested_resource.capitalize}CreateController"
                handler_name = "#{nested_resource.capitalize}CreateHandler"
                param_name = "#{singularize(resource_name)}_id"
                r.params[param_name] = id

                ROUTES_MAIN.(controller_name: controller_name, handler_name: handler_name, r: r)
              end
            end
          end
        end
      end
    }

    # Register routes for a specific resource
    def self.register_resource_routes(resource_name)
      controllers_dir = File.join(routes_path, resource_name, 'controllers')
      handlers_dir = File.join(routes_path, resource_name, 'handlers')

      # Load all controllers and handlers
      Dir.glob(File.join(controllers_dir, '*.rb')).each do |file|
        require File.expand_path(file)
      end

      Dir.glob(File.join(handlers_dir, '*.rb')).each do |file|
        require File.expand_path(file)
      end

      # Get the current route block
      current_route_block = @route_block
      # p current_route_block

      # Create a new route block that includes our resource routes
      route do |r|
        # First evaluate the existing routes
        instance_exec(r, &current_route_block)

        # Then add our resource routes
        r.on resource_name do
          # Index route
          r.is do
            r.get do
              controller_name = "#{resource_name.capitalize}IndexController"
              handler_name = "#{resource_name.capitalize}IndexHandler"

              ROUTES_MAIN.(controller_name: controller_name, handler_name: handler_name, r: r)
            end

            # Create route
            r.post do
              controller_name = "#{resource_name.capitalize}CreateController"
              handler_name = "#{resource_name.capitalize}CreateHandler"

              ROUTES_MAIN.(controller_name: controller_name, handler_name: handler_name, r: r)
            end
          end

          # Show, Update, Delete routes
          r.on String do |id|
            r.params['id'] = id

            # Handle nested resources first
            nested_resources = self.class.nested_resources || {}
            ROUTES_NESTED.(nested_resources: nested_resources, resource_name: resource_name, id: id, r: r)


            r.is do
              r.get do
                controller_name = "#{resource_name.capitalize}ShowController"
                handler_name = "#{resource_name.capitalize}ShowHandler"

                ROUTES_MAIN.(controller_name: controller_name, handler_name: handler_name, r: r)
              end

              r.post do
                controller_name = "#{resource_name.capitalize}UpdateController"
                handler_name = "#{resource_name.capitalize}UpdateHandler"

                ROUTES_MAIN.(controller_name: controller_name, handler_name: handler_name, r: r)
              end
            end

            # Delete route
            r.post "delete" do
              controller_name = "#{resource_name.capitalize}DeleteController"
              handler_name = "#{resource_name.capitalize}DeleteHandler"

              ROUTES_MAIN.(controller_name: controller_name, handler_name: handler_name, r: r)
            end
          end
        end
      end
    end

    # Register a nested resource
    def self.register_nested_resource(parent_resource, child_resource)
      self.nested_resources ||= {}
      self.nested_resources[parent_resource] ||= []
      self.nested_resources[parent_resource] << child_resource unless self.nested_resources[parent_resource].include?(child_resource)
    end
  end

  # Base controller class for MK framework
  class Controller
    class << self
      def route(&block)
        define_method(:route_block) do
          block
        end
      end
    end

    def execute(r)
      # Execute the route block in the controller's context
      # This allows the controller to access instance variables and methods
      instance_exec(r, &route_block)
    end
  end

  # Base handler class for MK framework
  class Handler
    attr_reader :model

    class << self
      def route(&block)
        define_method(:route_block) do
          block
        end
      end

      # New method for handler class definition
      def handler(&block)
        define_method(:handler_block) do
          block
        end
      end
    end

    def initialize(model)
      @model = model
      @model_name = model.class.name.downcase if model.is_a?(Sequel::Model)
      @success_block = nil
      @fail_block = nil

      # Dynamically define accessors for the model
      define_model_accessors if model
    end

    def success(&block)
      @success_block = block
      self
    end

    def error(&block)
      @fail_block = block
      self
    end

    def execute(r)
      begin
        handler_name = self.class.name

        result = instance_exec(r, &handler_block)

        # Handle different types of handlers
        if handler_name.end_with?('IndexHandler')
          # For index and show handlers, return the model directly
          return result
        end

        if handler_name.end_with?('ShowHandler')
          # For index and show handlers, return the model directly

          unless result.is_a? Sequel::Model
            return result
          else
            puts "ERROR"
            puts "You can't return a sequel model from the ShowHandler"
            r.halt 500, {
              error: "Server error",
              message: "Internal resource error"
            }
          end
        end

        # For other cases (create, update, delete with success/failure blocks)
        if handler_name.end_with?('CreateHandler') || handler_name.end_with?('UpdateHandler') || handler_name.end_with?('DeleteHandler')
          if @success_block && @fail_block
            begin
              unless handler_name.end_with?('DeleteHandler')
                if model.save
                  return instance_exec(r, &@success_block)
                else
                  return instance_exec(r, &@fail_block)
                end
              else
                if model.is_a?(Sequel::Model)
                  if model.delete
                    return instance_exec(r, &@success_block)
                  else
                    return instance_exec(r, &@fail_block)
                  end
                else
                  puts "ERROR"
                  puts "You need to return a sequel model from the DeleteController"
                  r.halt 500, {
                    error: "Server error",
                    message: "Internal resource error"
                  }
                end
              end
            rescue Sequel::ValidationFailed => e
              return instance_exec(r, &@fail_block)
            rescue StandardError => e
              # Handle other errors
              r.response.status = 500
              puts "ERROR:"
              puts e.message
              puts e.backtrace.join("\n")
              r.halt 500, {
                error: "Server error",
                message: e.message
              }
            end
          else
            raise "Success and Error blocks are required for create, update, and delete actions" unless handler_name.end_with?('IndexHandler') || handler_name.end_with?('ShowHandler')
          end
        end
        raise "No Handler Block Found".inspect
      rescue StandardError => e
        error_info = {
          handler_class: handler_name,
          model_class: model ? model.class.name : nil,
          model_state: model.is_a?(Sequel::Model) ? model.values : nil
          }.to_yaml
        puts "ERROR:"
        puts error_info
        raise e  # Re-raise to be caught by the application error handler
      end
    end

    private

    # Recursively serialize objects to JSON-compatible hashes
    def serialize(obj)
      case obj
      when Sequel::Model
        obj.to_hash
      when Hash
        result = {}
        obj.each do |key, value|
          result[key] = serialize(value)
        end
        result
      when Array
        obj.map { |item| serialize(item) }
      else
        obj
      end
    end

    # Define accessors for model object dynamically using define_method
    def define_model_accessors
      # First define a method to access the model directly
      self.class.class_eval do
        define_method(@model_name.to_sym) { @model } if @model.is_a?(Sequel::Model)
      end

      # Then define methods for all model attributes
      if @model.is_a?(Sequel::Model)
        @model.columns.each do |column|
          self.class.class_eval do
            define_method(column) { @model[column] }
            define_method("#{column}=") { |value| @model[column] = value }
          end
        end
      end
    end
  end
end
