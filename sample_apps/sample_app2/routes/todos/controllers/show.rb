# frozen_string_literal: true

require_relative 'base'

module SampleApp2
  class TodosShowController < TodosController
    route do |r|
      find(r)
    end
  end
end
