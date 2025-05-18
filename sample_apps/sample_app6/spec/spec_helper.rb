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

class StrictHash < Hash
  def [](key)
    fetch(key)
  end
end

module SymbolizeHelper
  def symbolize_recursive(hash)
    StrictHash.new.tap do |h|
      hash.each { |key, value| h[key.to_sym] = map_value(value) }
    end
  end

  def map_value(thing)
    case thing
    when Hash, StrictHash
      symbolize_recursive(thing)
    when Array
      thing.map { |v| map_value(v) }
    else
      thing
    end
  end
end

module MK; end
module MK::Framework; end
module MK::Framework::Spec

  include SymbolizeHelper

  def resp
    @last_json ||= parse_response_body last_response.body
  end

  def parse_response_body(response_body)
    return StrictHash.new if response_body.nil? || response_body.empty?
    response_body = JSON.parse(response_body)
    case response_body
    when Hash
      StrictHash[ symbolize_recursive response_body ]
    when Array
      response_body.map { |value| StrictHash[ symbolize_recursive value ] }
    else
      response_body
    end
  end

  include Rack::Test::Methods
  %i[get post put patch delete head].each do |method|
    define_method "#{method}_with_clear_cache" do |*args, &block|
      @last_json = nil
      send("#{method}_without_clear_cache", *args, &block)
    end

    alias_method "#{method}_without_clear_cache", method
    alias_method method, "#{method}_with_clear_cache"
  end
end

# Configure RSpec
RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    WeatherApp.app
  end

  config.include MK::Framework::Spec
end
