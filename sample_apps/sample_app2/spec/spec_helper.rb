# frozen_string_literal: true

require "rspec"
require "rack/test"
require "json"

# Load the application
require_relative '../app'

# Configure RSpec
RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    TodoApp.app
  end
end
