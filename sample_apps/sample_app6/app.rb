# frozen_string_literal: true

require_relative '../../lib/mk_framework/sequel'
require_relative 'database'
require_relative 'models/weather'

module SampleApp6
  class Controller < MK::Controller
    include MK::Persistence
  end

  class App < MK::Application
    def self.api_key = ENV['OPENWEATHERMAP_API_KEY']

    configure root: ROOT, namespace: SampleApp6

    resource_routes do
      resources :weather, only: %i[index show], param: :location
    end
  end

  App.boot!
end
