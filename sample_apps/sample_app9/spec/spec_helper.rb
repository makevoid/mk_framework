# frozen_string_literal: true

require "rspec"
require "rack/test"
require "json"

# Load the application
require_relative '../app'
require_relative '../../../lib_spec/mk_framework_spec_helpers'

# Configure RSpec
RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    TodoApp.app
  end

  config.include MK::Framework::Spec
end
