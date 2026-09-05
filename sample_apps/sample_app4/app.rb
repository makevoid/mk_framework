# frozen_string_literal: true

require_relative '../../lib/mk_framework/sequel'
require_relative 'database'
require_relative 'models/post'
require_relative 'models/comment'

module SampleApp4
  class Controller < MK::Controller
    include MK::Persistence
  end

  class App < MK::Application
    configure root: ROOT, namespace: SampleApp4

    resource_routes do
      resources :posts do
        resources :comments
      end
      resources :comments, only: %i[show update delete]
    end
  end

  App.boot!
end
