# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'rack/test'
require 'rack/builder'
require 'json'

require_relative '../database'
SampleDatabase.migrate(SampleApp1::DB, root: SampleApp1::ROOT)
require_relative '../app'
require_relative '../../../lib_spec/mk_framework_spec_helpers'

RSpec.configure do |config|
  config.include MK::Framework::Spec
  config.after(:suite) { SampleApp1::DB.disconnect }
end

def app
  SampleApp1::App.app
end
