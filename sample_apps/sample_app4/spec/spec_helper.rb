# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'rack/test'
require 'rack/builder'
require 'json'

require_relative '../database'
SampleDatabase.migrate(SampleApp4::DB, root: SampleApp4::ROOT)
require_relative '../app'
require_relative '../../../lib_spec/mk_framework_spec_helpers'

RSpec.configure do |config|
  config.include MK::Framework::Spec
  config.after(:suite) { SampleApp4::DB.disconnect }
end

def app
  SampleApp4::App.app
end
