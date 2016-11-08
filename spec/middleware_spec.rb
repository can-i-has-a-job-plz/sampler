# frozen_string_literal: true
describe Sampler::Middleware, type: :request do
  let(:sampler_app) { RequestHelper::SamplerApp.new }
  subject(:delegate) { ->(*args) { @args = args } }
  before do
    allow(RequestHelper::SamplerApp).to receive(:new).and_return(sampler_app)
    Sampler::Notifications.subscribe('request.sampler', delegate)
  end

  it 'should send request.sampler notifications' do
    should receive(:call).with('request.sampler', any_args).once
    get '/'
  end

  context 'env' do
    let(:original_env) { Rack::MockRequest.env_for('some_path') }

    it 'should not be modified' do
      expect(sampler_app).to receive(:call).with(original_env).and_call_original
      app.call(original_env.dup)
    end

    context 'rack.input' do
      before do
        allow(sampler_app).to receive(:call) do |env|
          Rack::Response.new(env['rack.input'].read)
        end
        post '/index', key: :value
      end
      it 'should not be modified' do
        expect(last_response.body).to eq('key=value')
      end
    end
  end

  RSpec.shared_examples 'should contain original' do |key, value, attr = key|
    it "should contain #{key} from orignal request" do
      expect(payload[key]).to eq(value)
    end
    it "should contain #{key} that differs from payload[:request] one" do
      expect(payload[:request].send(attr)).not_to eq(value)
    end
  end

  shared_examples 'common notification payload' do
    subject(:payload) { @args.last }
    before do
      # Messing with request to be sure that we have original values in payload
      payload[:request].env['PATH_INFO'] = '/fake'
      payload[:request].instance_variable_set(:@fullpath, nil)
      payload[:request].instance_variable_set(:@method, 'MKCALENDAR')
      payload[:request].env['action_dispatch.request.parameters'] = {}
      # FIXME: see comment in RequestHelper
      payload[:request].env['rack.input'] = StringIO.new('fake')
    end
    it { should have_key(:endpoint) }
    include_examples 'should contain original', :endpoint, '/index', :path
    it { should have_key(:request) }
    it 'should contain ActionDispatch::Request as request' do
      expect(payload[:request]).to be_a(ActionDispatch::Request)
    end
    it { should have_key(:url) }
    include_examples 'should contain original', :url,
                     'http://example.org/index?x=1'
    it { should have_key(:method) }
    include_examples 'should contain original', :method, :post, :method_symbol
    it { should have_key(:params) }
    include_examples 'should contain original', :params, 'x' => '1',
                                                         'key' => 'value'
    it { should have_key(:request_body) }
    it 'should contain request body from orignal request' do
      expect(payload[:request_body]).to eq('key=value')
    end
    it 'should contain request body that differs from payload[:request] one' do
      expect(payload[:request_body]).not_to eq(payload[:request].body.read)
    end
    it { should have_key(:response) }
    it 'should contain ActionDispatch::Response as response' do
      expect(payload[:response]).to be_a(ActionDispatch::Response)
    end
    it { should have_key(:response_body) }
  end

  context 'when Rack app works ok' do
    before do
      post '/index?x=1', key: :value
      payload[:response].body = 'fake'
    end
    include_examples 'common notification payload'

    it 'should contain the same request body as response' do
      expect(payload[:response_body]).to eq(last_response.body)
    end
    it 'should contain request body that differs from payload[:response] one' do
      expect(payload[:response_body]).not_to eq(payload[:response].body)
    end
  end

  context 'when Rack app raises' do
    before do
      allow(sampler_app).to receive(:call).and_raise(ArgumentError, 'message')
      # rubocop:disable Style/RescueModifier
      post '/index?x=1', key: :value rescue nil
      # rubocop:enable Style/RescueModifier
    end
    include_examples 'common notification payload'

    it 'should reraise exception' do
      expect { get '/' }.to raise_error(ArgumentError).with_message('message')
    end

    it 'should contain empty request body' do
      expect(payload[:response_body]).to eq('')
    end
  end
end
