# frozen_string_literal: true

module SampleApp6
  class WeatherIndexController < Controller
    route do |r|
      paginate(Weather.dataset, r)
    end
  end
end
