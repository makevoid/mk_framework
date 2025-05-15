# frozen_string_literal: true

require "rspec"
require "rack/test"
require "json"

# Load the application
require_relative '../app'

module MK::Framework::Spec
  def resp
    @last_json ||= {}
    @last_json[last_response.object_id] ||= JSON.parse(last_response.body)
  end
  
  # Clear the cached JSON when a new request is made
  %i[get post put patch delete head].each do |method|
    define_method "#{method}_with_clear_cache" do |*args, &block|
      @last_json = {}
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
    TodoApp.app
  end
  
  config.include MK::Framework::Spec
end
