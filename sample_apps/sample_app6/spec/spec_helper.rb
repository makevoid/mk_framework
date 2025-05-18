# frozen_string_literal: true

require "rspec"
require "rack/test"
require "json"
require "vcr"
require "webmock/rspec"

# Configure VCR
VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false
  # Filter sensitive data
  config.filter_sensitive_data('<API_KEY>') { WeatherApp.api_key }
  # Allow VCR to match the request more loosely
  config.default_cassette_options = {
    record: :once,
    match_requests_on: [:method, :host, :path]
  }
end

# Load the application
require_relative '../app'

require_relative '../../../lib_spec/mk_framework_spec_helpers'

# Configure RSpec
RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    WeatherApp.app
  end

  config.include MK::Framework::Spec
end
