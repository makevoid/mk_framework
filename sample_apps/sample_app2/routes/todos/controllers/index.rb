# frozen_string_literal: true

require_relative 'base'

module SampleApp2
  class TodosIndexController < TodosController
    route do |r|
      paginate(dataset(r), r)
    end
  end
end
