# frozen_string_literal: true

module MK
  class Routes
    ACTIONS = {index: ['GET', false], create: ['POST', false], show: ['GET', true],
               update: ['PATCH', true], delete: ['DELETE', true]}.freeze
    attr_reader :endpoints

    def initialize(namespace:, legacy:, endpoints: [], prefix: [], scope_prefix: [])
      @namespace, @legacy, @endpoints = namespace, legacy, endpoints
      @prefix, @scope_prefix = prefix, scope_prefix
    end

    def self.camelize(name) = name.to_s.split('_').map(&:capitalize).join

    def self.singularize(name)
      irregular = {'people' => 'person', 'children' => 'child', 'men' => 'man', 'women' => 'woman'}
      irregular.fetch(name) do
        name.end_with?('ies') ? "#{name[0...-3]}y" : name.sub(/(?<!s)s\z/, '')
      end
    end

    def scope(path, &block)
      parts = path.to_s.split('/').reject(&:empty?)
      self.class.new(namespace: @namespace, legacy: @legacy, endpoints: @endpoints,
                     prefix: @prefix + parts, scope_prefix: @scope_prefix + parts).instance_eval(&block)
    end

    def namespace(name, &block)
      mod = @namespace.const_get(Routes.camelize(name), false)
      Routes.new(namespace: mod, legacy: @legacy, endpoints: @endpoints,
                 prefix: @prefix + [name.to_s], scope_prefix: @scope_prefix + [name.to_s]).instance_eval(&block)
    end

    def resources(name, only: ACTIONS.keys, singular: nil, param: :id, parent_key: nil,
                  shallow: false, namespace: @namespace, actions: {}, legacy: @legacy, &block)
      name = name.to_s
      raise ConfigurationError, "Invalid resource path: #{name}" unless name.match?(/\A[a-zA-Z0-9_-]+\z/)

      singular ||= Routes.singularize(name)
      collection_path = @prefix + [name]
      member_path = (shallow ? @scope_prefix + [name] : collection_path) + [param.to_sym]
      child_path = member_path[0...-1] + [(parent_key || "#{singular}_id").to_sym]
      resource = ResourceRoutes.new(namespace: namespace, legacy: legacy, endpoints: @endpoints,
                                    prefix: child_path, scope_prefix: @scope_prefix)
      resource.collection_path, resource.member_path = collection_path, member_path
      resource.resource_name, resource.label = name, Routes.camelize(singular)
      only.each do |action|
        verb, member = ACTIONS.fetch(action.to_sym) { raise ConfigurationError, "Unknown action: #{action}" }
        pair = actions[action.to_sym]
        resource.add(verb, member ? member_path : collection_path, action,
                     controller: pair&.fetch(0), handler: pair&.fetch(1))
        if action.to_sym == :update
          resource.add('PUT', member_path, action, controller: pair&.fetch(0), handler: pair&.fetch(1))
        end
        if legacy && action.to_sym == :update
          resource.add('POST', member_path, action, controller: pair&.fetch(0), handler: pair&.fetch(1))
        elsif legacy && action.to_sym == :delete
          resource.add('POST', member_path + ['delete'], action, controller: pair&.fetch(0), handler: pair&.fetch(1))
        end
      end
      resource.instance_eval(&block) if block
    end
  end

  class ResourceRoutes < Routes
    attr_accessor :collection_path, :member_path, :resource_name, :label

    def member(action, via:, controller: nil, handler: nil)
      add(via, member_path + [action.to_s], action, controller: controller, handler: handler)
    end

    def collection(action, via:, controller: nil, handler: nil)
      add(via, collection_path + [action.to_s], action, controller: controller, handler: handler)
    end

    def add(verb, path, action, controller:, handler:)
      prefix = "#{Routes.camelize(resource_name)}#{Routes.camelize(action)}"
      controller ||= @namespace.const_get("#{prefix}Controller", false)
      handler ||= @namespace.const_get("#{prefix}Handler", false)
      unless controller <= Controller && controller.method_defined?(:route_block)
        raise ConfigurationError, "#{controller} must define a controller route block"
      end
      unless handler <= Handler && handler.method_defined?(:handler_block)
        raise ConfigurationError, "#{handler} must define a handler block"
      end
      names = path.grep(Symbol)
      raise ConfigurationError, "Duplicate path parameters in #{path.inspect}; set parent_key" unless names.uniq == names

      path = path.map { |part| part.is_a?(String) ? part.dup.freeze : part }.freeze
      @endpoints << {verb: verb.to_s.upcase.freeze, path: path, action: action.to_sym,
                     controller: controller, handler: handler, label: label.freeze, params: names.freeze}.freeze
    rescue NameError => error
      raise ConfigurationError, "Missing action for #{resource_name}.#{action}: #{error.message}"
    end
  end

  # A compiled trie. Literal branches take precedence over parameter captures.
  # Matching still uses Roda, including its exact-path and halt semantics.
  class Router
    Node = Struct.new(:literals, :dynamic, :methods, keyword_init: true)
    attr_reader :endpoints

    def initialize(endpoints)
      @endpoints = endpoints.freeze
      @root = new_node
      endpoints.each do |endpoint|
        node = endpoint[:path].inject(@root) do |branch, segment|
          segment.is_a?(Symbol) ? (branch.dynamic ||= new_node) : (branch.literals[segment] ||= new_node)
        end
        verb = endpoint[:verb]
        raise ConfigurationError, "Duplicate route: #{verb} /#{endpoint[:path].join('/')}" if node.methods.key?(verb)

        node.methods[verb] = endpoint
      end
      freeze_node(@root)
      freeze
    end

    def call(request, application)
      walk(@root, request, application, [])
    end

    private

    def new_node = Node.new(literals: {}, methods: {})

    def freeze_node(node)
      node.literals.each_value { |child| freeze_node(child) }
      freeze_node(node.dynamic) if node.dynamic
      node.literals.freeze
      node.methods.freeze
      node.freeze
    end

    def walk(node, request, application, captures)
      request.is do
        request.halt(404, {error: 'Not Found'}) if node.methods.empty?

        verb = request.head? ? 'GET' : request.request_method
        endpoint = node.methods[verb]
        unless endpoint
          allowed = node.methods.keys
          allowed += ['HEAD'] if allowed.include?('GET')
          request.response['allow'] = allowed.sort.join(', ')
          request.halt(405, {error: 'Method not allowed'})
        end
        request.env['mk.path_params'] = endpoint[:params].zip(captures).to_h.freeze
        request.params # Validate the body before controller side effects.
        application.dispatch(endpoint, request)
      end

      request.on String do |segment|
        if (child = node.literals[segment])
          walk(child, request, application, captures)
        elsif node.dynamic
          walk(node.dynamic, request, application, captures + [segment.freeze])
        else
          request.halt(404, {error: 'Not Found'})
        end
      end
      request.halt(404, {error: 'Not Found'})
    end
  end
end
