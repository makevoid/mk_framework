# frozen_string_literal: true

require 'roda'
require 'sequel'

module MK
  # Base MK application
  class Application < Roda
    plugin :all_verbs
    plugin :json
    plugin :json_parser
    plugin :halt

    # Class attribute to store routes path
    class << self
      attr_accessor :routes_path
    end

    # Implement the Roda application pattern correctly
    def self.inherited(subclass)
      super
      subclass.routes_path = 'routes'

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

    # Class method to load routes based on the directory structure
    def self.load_routes
      return unless routes_path

      Dir.glob(File.join(routes_path, '*')).each do |resource_dir|
        next unless File.directory?(resource_dir)

        resource_name = File.basename(resource_dir)
        register_resource_routes(resource_name)
      end
    end

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

      # Create a new route block that includes our resource routes
      route do |r|
        # First evaluate the existing routes
        result = instance_exec(r, &current_route_block) if current_route_block

        # Then add our resource routes
        r.on resource_name do
          # Index route
          r.is do
            r.get do
              controller_name = "#{resource_name.capitalize}IndexController"
              handler_name = "#{resource_name.capitalize}IndexHandler"

              if Object.const_defined?(controller_name) && Object.const_defined?(handler_name)
                controller = Object.const_get(controller_name).new
                result = controller.execute(r)

                handler = Object.const_get(handler_name).new(result)
                handler.execute(r)
              else
                response.status = 404
                { error: "Route not implemented" }
              end
            end

            # Create route
            r.post do
              controller_name = "#{resource_name.capitalize}CreateController"
              handler_name = "#{resource_name.capitalize}CreateHandler"

              if Object.const_defined?(controller_name) && Object.const_defined?(handler_name)
                controller = Object.const_get(controller_name).new
                result = controller.execute(r)

                handler = Object.const_get(handler_name).new(result)
                handler.execute(r)
              else
                response.status = 404
                { error: "Route not implemented" }
              end
            end
          end

          # Show, Update, Delete routes
          r.on String do |id|
            r.is do
              # Store id in params
              r.params['id'] = id

              # Show route
              r.get do
                controller_name = "#{resource_name.capitalize}ShowController"
                handler_name = "#{resource_name.capitalize}ShowHandler"

                if Object.const_defined?(controller_name) && Object.const_defined?(handler_name)
                  controller = Object.const_get(controller_name).new
                  result = controller.execute(r)

                  handler = Object.const_get(handler_name).new(result)
                  handler.execute(r)
                else
                  response.status = 404
                  { error: "Route not implemented" }
                end
              end

              # Update route
              r.is do
                r.post do
                  controller_name = "#{resource_name.capitalize}UpdateController"
                  handler_name = "#{resource_name.capitalize}UpdateHandler"

                  if Object.const_defined?(controller_name) && Object.const_defined?(handler_name)
                    controller = Object.const_get(controller_name).new
                    result = controller.execute(r)

                    handler = Object.const_get(handler_name).new(result)
                    handler.execute(r)
                  else
                    response.status = 404
                    { error: "Route not implemented" }
                  end
                end
              end

              # Delete route
              r.post "delete" do
                controller_name = "#{resource_name.capitalize}DeleteController"
                handler_name = "#{resource_name.capitalize}DeleteHandler"

                if Object.const_defined?(controller_name) && Object.const_defined?(handler_name)
                  controller = Object.const_get(controller_name).new
                  result = controller.execute(r)

                  handler = Object.const_get(handler_name).new(result)
                  handler.execute(r)
                else
                  response.status = 404
                  { error: "Route not implemented" }
                end
              end
            end
          end
        end
      end
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
    end

    def initialize(model)
      @model = model
      @model_name = model.class.name.downcase
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
      # Execute the handler's route block
      result = instance_exec(r, &route_block)

      # If the result is a model object, convert to hash (JSON-compatible)
      if result.is_a?(Sequel::Model)
        return result.to_hash
      end

      # If the result is a raw model (for index/show actions)
      if model && (self.class.name.end_with?('IndexHandler') || self.class.name.end_with?('ShowHandler'))
        return model.respond_to?(:map) ? model.map(&:to_hash) : model.to_hash
      end

      # For other cases (create, update, delete with success/failure blocks)
      if @success_block && @fail_block
        begin
          if model.save
            instance_exec(r, &@success_block)
          else
            instance_exec(r, &@fail_block)
          end
        rescue Sequel::ValidationFailed => e
          instance_exec(r, &@fail_block)
        rescue StandardError => e
          # Handle other errors
          r.response.status = 500
          return {
            error: "Server error",
            message: e.message
          }
        end
      else
        # Ensure we return a valid Roda response (String, Hash, Array)
        result
      end
    end

    private

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
