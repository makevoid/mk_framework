# frozen_string_literal: true

require_relative '../../lib/mk_framework/sequel'
require_relative 'database'
require_relative 'models/todo'

module SampleApp3
  class Controller < MK::Controller
    include MK::Persistence
  end

  class App < MK::Application
    configure root: ROOT, namespace: SampleApp3

    resource_routes do
      resources :todos
    end
  end

  App.boot!
end
