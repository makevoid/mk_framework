# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
require 'rspec'
require 'rack/test'
require 'rack/builder'
require 'json'

require_relative '../database'
SampleDatabase.migrate(SampleApp2::DB, root: SampleApp2::ROOT)
require_relative '../app'
require_relative '../../../lib_spec/mk_framework_spec_helpers'

RSpec.configure do |config|
  config.include MK::Framework::Spec
  config.after(:suite) { SampleApp2::DB.disconnect }
end

def app
  SampleApp2::App.app
end
