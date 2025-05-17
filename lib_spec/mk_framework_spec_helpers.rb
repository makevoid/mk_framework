
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
