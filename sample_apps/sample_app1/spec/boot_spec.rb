# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Rack entrypoint' do
  it 'boots through config.ru from another working directory' do
    rack_app = Dir.chdir(File::SEPARATOR) { Rack::Builder.parse_file(File.join(SampleApp1::ROOT, 'config.ru')) }
    response = Rack::MockRequest.new(rack_app).get('/')
    expect(response.status).to eq(200)
    expect(response.content_type).to eq('application/json')
  end
end
