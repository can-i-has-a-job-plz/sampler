# frozen_string_literal: true
describe Sampler::Middleware, type: :request do
  let(:sampler_app) { RequestHelper::SamplerApp.new }
  subject(:delegate) { ->(*args) { @args = args } }
  before do
    allow(RequestHelper::SamplerApp).to receive(:new).and_return(sampler_app)
    ActiveSupport::Notifications.subscribe('request.sampler', delegate)
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
    end
    it { should have_key(:endpoint) }
    include_examples 'should contain original', :endpoint, '/index', :path
    it { should have_key(:request) }
    it { should have_key(:url) }
    include_examples 'should contain original', :url,
                     'http://example.org/index?x=1'
    it { should have_key(:method) }
    include_examples 'should contain original', :method, :post, :method_symbol
    it { should have_key(:params) }
    include_examples 'should contain original', :params, 'x' => '1',
                                                         'key' => 'value'
  end

  context 'when Rack app works ok' do
    before { post '/index?x=1', key: :value }
    include_examples 'common notification payload'
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
  end
end
