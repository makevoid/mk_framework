# frozen_string_literal: true

require "rspec"
require "rack/test"
require "json"

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
    when Hash
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
    @last_json ||= StrictHash[ symbolize_recursive JSON.parse(last_response.body) ]
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
    TodoApp.app
  end

  config.include MK::Framework::Spec
end
