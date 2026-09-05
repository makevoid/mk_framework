# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'rack/test'
require 'rack/builder'
require 'json'
require 'webmock/rspec'
WebMock.disable_net_connect!
ENV['OPENWEATHERMAP_API_KEY'] = 'test-weather-key'
require_relative '../database'
SampleDatabase.migrate(SampleApp6::DB, root: SampleApp6::ROOT)
require_relative '../app'
require_relative '../../../lib_spec/mk_framework_spec_helpers'

RSpec.configure do |config|
  config.include MK::Framework::Spec
  config.after(:suite) { SampleApp6::DB.disconnect }
end

def app = SampleApp6::App.app
