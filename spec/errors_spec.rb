# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Request and error boundaries' do
  let(:log) { StringIO.new }

  it 'sanitizes unexpected production errors and uses the configured logger and request ID' do
    app = build_app(logger: Logger.new(log), custom: proc { |r| r.params; raise 'private SQL credential' })
    response = request(app, 'POST', '/', input: '{"nested":{"password":"hidden","api_key":"hidden"},"items":[{"token":"hidden"}],"ssn":"hidden"}')
    expect(response.status).to eq(500)
    expect(response.content_type).to eq('application/json')
    expect(response.body).not_to include('private', 'hidden')
    expect(body(response)['request_id']).to eq(response['x-request-id'])
    expect(log.string).to include('RuntimeError', '[FILTERED]')
    expect(log.string).not_to include('private SQL credential')
    expect(JSON.parse(log.string.lines.last.sub(/^.*?\{/, '{'))['params']['ssn']).to eq('hidden')
  end

  it 'recursively filters configurable fields including arrays' do
    app = build_app(logger: Logger.new(log), filter_parameters: ['ssn'], custom: proc { |r| r.params; raise 'failure' })
    request(app, 'POST', '/', input: '{"ssn":"private-ssn","items":[{"password":"private-password"}]}')
    expect(log.string).not_to include('private-ssn', 'private-password')
  end

  it 'returns safe 400 JSON for malformed or non-object JSON without breaking its own handler' do
    app = build_app(custom: proc { |r| r.params; {ok: true} })
    ['{', '[]', 'null', '123', '"string"'].each do |input|
      response = request(app, 'POST', '/', input: input)
      expect(response.status).to eq(400)
      expect(response.content_type).to eq('application/json')
      expect(body(response)['error']).to eq('Expected a valid JSON object')
    end
  end

  it 'does not treat programming KeyErrors as bad user input' do
    app = build_app(custom: proc { |_r| {}.fetch(:missing) })
    expect(request(app, 'GET', '/').status).to eq(500)
  end

  it 'handles malformed query parameters as a 400' do
    app = build_app(custom: proc { |r| r.params; {ok: true} })
    expect(request(app, 'GET', '/?a=1&a[b]=2').status).to eq(400)
  end

  it 'returns development details without replacing the original exception' do
    app = build_app(environment: 'development', custom: proc { |_r| raise 'debug detail' })
    result = body(request(app, 'GET', '/'))
    expect(result.fetch('debug')).to include('error_class' => 'RuntimeError', 'message' => 'debug detail')
  end

  it 'survives exceptions without backtraces and failed log sinks' do
    error = RuntimeError.new('test')
    allow(error).to receive(:backtrace).and_return(nil)
    logger = double(error: nil)
    allow(logger).to receive(:error).and_raise(IOError)
    app = build_app(logger: logger, custom: proc { |_r| raise error })
    expect(request(app, 'GET', '/').status).to eq(500)
  end

  it 'bounds request bodies even without Content-Length and accepts empty bodies' do
    app = build_app(max_body_bytes: 16, custom: proc { |_r| {ok: true} })
    expect(request(app, 'POST', '/', input: '').status).to eq(200)
    env = Rack::MockRequest.env_for('/', method: 'POST', input: 'a' * 17)
    env.delete('CONTENT_LENGTH')
    response = Rack::MockResponse.new(*Rack::Lint.new(app.app).call(env))
    expect(response.status).to eq(413)
    expect(response['x-request-id']).not_to be_nil
    expect(response.content_type).to eq('application/json')
  end

  it 'validates and allows only declared input fields, preserving explicit false and null' do
    app = build_app(custom: proc { |r|
      {required: r.input.require(:title), fields: r.input.permit(completed: :boolean, description: [String, NilClass])}
    })
    response = request(app, 'POST', '/', input: '{"title":"ok","completed":false,"description":null,"admin":true}')
    expect(body(response)).to eq('required' => 'ok', 'fields' => {'completed' => false, 'description' => nil})
    expect(request(app, 'POST', '/', input: '{}').status).to eq(400)
    expect(request(app, 'POST', '/', input: '{"title":[]}').status).to eq(400)
  end

  it 'validates pagination instead of allowing unbounded queries or negative offsets' do
    app = build_app(custom: proc { |r| r.page })
    expect(body(request(app, 'GET', '/'))).to eq('limit' => 25, 'offset' => 0)
    %w[limit=101 limit=0 limit=hello offset=-1 offset=10001].each do |query|
      expect(request(app, 'GET', "/?#{query}").status).to eq(400)
    end
  end
end
