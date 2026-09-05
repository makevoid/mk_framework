# frozen_string_literal: true

module MK
  class Controller
    def self.route(&block)
      define_method(:route_block) { block }
    end

    def execute(request)
      instance_exec(request, &route_block)
    end
  end

  class Handler
    attr_reader :model

    def self.handler(&block)
      define_method(:handler_block) { block }
    end

    # Old applications used `route` for response blocks.
    class << self
      alias route handler
    end

    def initialize(value)
      @model = value
    end

    def execute(request)
      instance_exec(request, &handler_block)
    end

    # Select fields explicitly instead of exposing future database columns.
    def fields(record, *names)
      names.to_h { |name| [name, record[name]] }
    end
  end
end
