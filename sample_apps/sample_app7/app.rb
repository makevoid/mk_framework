# frozen_string_literal: true

require_relative '../../lib/mk_framework/sequel'
require_relative 'database'
require_relative 'models/card'
require_relative 'models/comment'

module SampleApp7
  class Controller < MK::Controller
    include MK::Persistence
  end

  class App < MK::Application
    configure root: ROOT, namespace: SampleApp7

    resource_routes do
      resources :board, only: [:index]
      resources :cards do
        member :move, via: :patch
        resources :comments
      end
      resources :comments, only: %i[show update delete]
    end
  end

  App.boot!
end
