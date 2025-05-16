# frozen_string_literal: true

require 'roda'
require 'sequel'

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
    # plugin :error_handler

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

    # Implement the Roda application pattern correctly
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
                # puts "Controller: #{controller_name} -- Handler: #{handler_name}" # DEBUG
                result = controller.execute(r)

                handler = Object.const_get(handler_name).new(result)
                handler.execute(r)
              else
                response.status = 404
                { error: "#{handler_name} Not Found" }
              end
            end

            # Create route
            r.post do
              controller_name = "#{resource_name.capitalize}CreateController"
              handler_name = "#{resource_name.capitalize}CreateHandler"

              if Object.const_defined?(controller_name) && Object.const_defined?(handler_name)
                controller = Object.const_get(controller_name).new
                # puts "Controller: #{controller_name} -- Handler: #{handler_name}" # DEBUG
                result = controller.execute(r)

                handler = Object.const_get(handler_name).new(result)
                handler.execute(r)
              else
                response.status = 404
                { error: "#{handler_name} Not Found" }
              end
            end
          end

          # Show, Update, Delete routes
          r.on String do |id|
            r.params['id'] = id

            # Handle nested resources first
            nr = self.class.nested_resources || {}
            if nr[resource_name] && !nr[resource_name].empty?
              nr[resource_name].each do |nested_resource|
                r.on nested_resource do
                  # GET /resource/:id/nested_resource - Index of nested resources
                  r.is do
                    r.get do
                      controller_name = "#{nested_resource.capitalize}IndexController"
                      handler_name = "#{nested_resource.capitalize}IndexHandler"
                      param_name = "#{singularize(resource_name)}_id"
                      r.params[param_name] = id

                      if Object.const_defined?(controller_name) && Object.const_defined?(handler_name)
                        # puts "Controller: #{controller_name} -- Handler: #{handler_name}" # DEBUG
                        controller = Object.const_get(controller_name).new
                        result = controller.execute(r)

                        handler = Object.const_get(handler_name).new(result)
                        handler.execute(r)
                      else
                        response.status = 404
                        { error: "#{handler_name} Not Found" }
                      end
                    end

                    # POST /resource/:id/nested_resource - Create nested resource
                    r.post do
                      controller_name = "#{nested_resource.capitalize}CreateController"
                      handler_name = "#{nested_resource.capitalize}CreateHandler"
                      param_name = "#{singularize(resource_name)}_id"
                      r.params[param_name] = id

                      if Object.const_defined?(controller_name) && Object.const_defined?(handler_name)
                        # puts "Controller: #{controller_name} -- Handler: #{handler_name}" # DEBUG
                        controller = Object.const_get(controller_name).new
                        result = controller.execute(r)

                        handler = Object.const_get(handler_name).new(result)
                        handler.execute(r)
                      else
                        response.status = 404
                        { error: "#{handler_name} Not Found" }
                      end
                    end
                  end
                end
              end
            end

            # Regular resource routes
            r.is do
              # Store id in params

              r.get do
                controller_name = "#{resource_name.capitalize}ShowController"
                handler_name = "#{resource_name.capitalize}ShowHandler"

                if Object.const_defined?(controller_name) && Object.const_defined?(handler_name)
                  # puts "Controller: #{controller_name} -- Handler: #{handler_name}" # DEBUG
                  controller = Object.const_get(controller_name).new
                  result = controller.execute(r)

                  handler = Object.const_get(handler_name).new(result)
                  handler.execute(r)
                else
                  response.status = 404
                  { error: "#{handler_name} Not Found" }
                end
              end

              r.post do
                controller_name = "#{resource_name.capitalize}UpdateController"
                handler_name = "#{resource_name.capitalize}UpdateHandler"

                if Object.const_defined?(controller_name) && Object.const_defined?(handler_name)
                  # puts "Controller: #{controller_name} -- Handler: #{handler_name}" # DEBUG
                  controller = Object.const_get(controller_name).new
                  result = controller.execute(r)

                  handler = Object.const_get(handler_name).new(result)
                  handler.execute(r)
                else
                  response.status = 404
                  { error: "#{handler_name} Not Found" }
                end
              end
            end

            # Delete route
            r.post "delete" do
              controller_name = "#{resource_name.capitalize}DeleteController"
              handler_name = "#{resource_name.capitalize}DeleteHandler"

              if Object.const_defined?(controller_name) && Object.const_defined?(handler_name)
                # puts "Controller: #{controller_name} -- Handler: #{handler_name}" # DEBUG
                controller = Object.const_get(controller_name).new
                result = controller.execute(r)

                handler = Object.const_get(handler_name).new(result)
                handler.execute(r)
              else
                response.status = 404
                { error: "#{handler_name} Not Found" }
              end
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
        # puts "DEFINING METHOD ROUTE BLOCK" # DEBUG
        define_method(:route_block) do
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
      # Execute the handler's route block
      result = instance_exec(r, &route_block)

      # If the result is a model object, convert to hash (JSON-compatible)
      if result.is_a?(Sequel::Model)
        return result
      end

      # If the result is a raw model (for index/show actions)
      if (self.class.name.end_with?('IndexHandler') || self.class.name.end_with?('ShowHandler'))
        return result
      end

      # For other cases (create, update, delete with success/failure blocks)
      if @success_block && @fail_block
        begin
          unless self.class.name.end_with?('DeleteHandler')
            if model.save
              # puts "SUCCESS" # DEBUG count successes
              instance_exec(r, &@success_block)
            else
              # puts "FAIL" # DEBUG count fails
              instance_exec(r, &@fail_block)
            end
          else
            if model.is_a?(Sequel::Model)
              if model.delete
                instance_exec(r, &@success_block)
              else
                instance_exec(r, &@fail_block)
              end
            else
              puts "ERROR"
              puts "You need to return a sequel model from the DeleteController"
              return {
                error: "Server error",
                message: "Internal resource error"
              }
            end
          end
        rescue Sequel::ValidationFailed => e
          instance_exec(r, &@fail_block)
        rescue StandardError => e
          # Handle other errors
          r.response.status = 500
          puts "ERROR:"
          puts e.message
          puts e.backtrace.join("\n")
          return {
            error: "Server error",
            message: e.message
          }
        end
      else
        raise "Success and Error blocks are required for create, update, and delete actions"
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
