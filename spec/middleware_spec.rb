# frozen_string_literal: true
describe Sampler::Middleware, type: :request do
  let(:sampler_app) { RequestHelper::SamplerApp.new }
  before do
    allow(RequestHelper::SamplerApp).to receive(:new).and_return(sampler_app)
  end

  shared_examples 'should not modify request' do
    context 'request' do
      let(:original_env) { Rack::MockRequest.env_for('some_path') }
      before do
        allow(sampler_app).to receive(:call) do |env|
          Rack::Response.new(env['rack.input'].read)
        end
      end

      it 'env should not be modified' do
        expect(sampler_app).to receive(:call).with(original_env)
        app.call(original_env.dup)
      end

      it 'body should not be modified' do
        put '/index', k: :v
        expect(last_response.body).to eq('k=v')
      end
    end
  end

  shared_examples 'should not modify response' do
    context 'response' do
      let(:response) do
        Rack::Response.new('FakeResponse', 201, header_name: :header_value)
      end
      before do
        allow(sampler_app).to receive(:call).and_return(response)
        get '/'
      end
      it 'body should not be modified' do
        expect(last_response.body).to eq('FakeResponse')
      end
      it 'status should not be modified' do
        expect(last_response.status).to eq(response.status)
      end
      it 'headers should not be modified' do
        expect(last_response.headers).to eq(response.headers)
      end
    end
  end

  shared_examples 'should not modify request/response' do
    include_examples 'should not modify request'
    include_examples 'should not modify response'
  end

  include_examples 'should not modify request/response'
end
