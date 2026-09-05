# frozen_string_literal: true

require_relative 'base'

module SampleApp3
  class TodosDeleteController < TodosController
    route do |r|
      find(r)
    end
  end
end
