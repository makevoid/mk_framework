# frozen_string_literal: true

require_relative '../../lib/mk_framework/sequel'
require_relative 'database'
require_relative 'models/card'
require_relative 'models/comment'

module SampleApp5
  class Controller < MK::Controller
    include MK::Persistence
  end

  class App < MK::Application
    configure root: ROOT, namespace: SampleApp5

    resource_routes do
      resources :cards do
        resources :comments
      end
      resources :comments, only: %i[show update delete]
    end
  end

  App.boot!
end
