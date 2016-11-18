# frozen_string_literal: true
describe Sampler::Middleware, type: :request do
  let(:sampler_app) { RequestHelper::SamplerApp.new }
  let(:events) { Sampler.configuration.event_processor.events }
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
        action.call
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
        action.call
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

  shared_examples 'should save an event' do
    subject { action }
    let!(:event) { Sampler::Event.new }
    before do
      expect(Sampler::Event).to receive(:new) do |endpoint, request, *_args|
        event.endpoint = endpoint
        event.request = request
        event
      end
    end

    include_examples 'should not modify request/response'
    context 'when queue does not exist' do
      it 'should create only one queue' do
        should change { events.keys }.to([endpoint])
      end
      it 'should create events in proper queue' do
        should change { events.key?(endpoint) }.to(true)
      end
      it 'should add event to queue' do
        action.call
        expect(events[endpoint]).to eq([event])
      end
    end

    context 'when queue alread has an event' do
      let(:old_event) { Object.new }
      before { events[endpoint] << old_event }
      it 'should not create a queue' do
        should_not change { events.keys }
      end
      it 'should add an event to existing ones' do
        should change { events[endpoint] }.from([old_event])
          .to([old_event, event])
      end
    end
  end

  shared_examples 'should not save an event' do
    subject { action }
    include_examples 'should not modify request/response'
    context 'if queue does not exist yet' do
      it 'should not create a queue' do
        should_not change(events, :keys)
      end
    end
    context 'when queue already exists' do
      it 'should not create a new event' do
        should_not change { events[endpoint] }
      end
    end
  end

  shared_examples 'when route resolve raised' do
    context 'when route resolve raised' do
      let(:find_routes) { Object.new }
      let(:logger) { Sampler.configuration.logger }
      let(:endpoint) { nil }
      before do
        allow(Rails.application.routes.router).to receive(:method)
          .with(:find_routes).and_return(find_routes)
        allow(find_routes).to receive(:call).and_raise(ArgumentError, 'message')
      end
      it 'should log a warning' do
        msg = format(Sampler::Middleware::RESOLVE_ERROR, 'message',
                     "http://example.org#{path}?x=1")
        expect(logger).to receive(:warn).with(msg).and_call_original
        action.call
      end
      include_examples 'should not save an event'
    end
  end

  context 'when there is no route' do
    let(:path) { '/does_not_exist' }
    let(:action) { -> { put path, k: :v } }
    let(:endpoint) { 'not#found' }
    context 'event should be saved to queue not#found' do
      include_examples 'should save an event'
    end
  end

  shared_examples 'saving events' do
    context 'when route is successfully resolved' do
      include_examples 'should save an event'
    end
    include_examples 'when route resolve raised'
  end

  shared_examples 'should contain frozen original' do |key, value|
    it "should contain #{key} from orignal request" do
      expect(event[key]).to eq(value)
    end
    it "should contain frozen #{key}" do
      expect(event[key]).to be_frozen
    end
    it "should contain #{key} that differs from payload[:request] one" do
      expect(event.request.send(key)).not_to eq(value)
    end
  end

  shared_examples 'saved event' do
    subject(:event) { events[endpoint].last }
    let(:start) { Time.at(1.day).in_time_zone("Nuku'alofa") }
    before do
      expect(Time).to receive(:now).and_return(start).ordered
      expect(sampler_app).to receive(:call).and_call_original.ordered
      action.call
      # Messing with request to be sure that we have original values in event
      event.request.env['PATH_INFO'] = '/fake'
      event.request.instance_variable_set(:@fullpath, nil)
      event.request.instance_variable_set(:@method, 'MKCALENDAR')
      event.request.env['action_dispatch.request.parameters'] = {}
      # FIXME: see comment in RequestHelper
      event.request.env['rack.input'] = StringIO.new('fake')
    end
    it 'should have proper endpoint' do
      expect(event.endpoint).to eq(endpoint)
    end
    include_examples 'should contain frozen original', :url,
                     'http://example.org/authors/123?x=1'
    include_examples 'should contain frozen original', :method, 'PUT'
    include_examples 'should contain frozen original', :params, 'x' => '1',
                                                                'k' => 'v'
    it 'should have ActionDispatch::Request as request' do
      expect(event.request).to be_a(ActionDispatch::Request)
    end
    it 'should have proper start time' do
      expect(event.start).to eq(start)
    end
    it 'should have start time in UTC' do
      expect(event.start.zone).to eq('UTC')
    end
    it 'should contain request body from orignal request' do
      expect(event.request_body).to eq('k=v')
    end
    it 'should contain request body that differs from request one' do
      expect(event.request_body).not_to eq(event.request.body.read)
    end
  end

  context 'with Rack app' do
    let(:path) { '/authors/123' }
    let(:endpoint) { '/authors/:id(.:format)' }

    context 'that works ok' do
      let(:action) { -> { put "#{path}?x=1", k: :v } }

      include_examples 'saving events'
      context 'saved event' do
        include_examples 'saved event'
      end
    end

    context 'that raises' do
      # rubocop:disable Style/RescueModifier
      let(:action) { -> { put "#{path}?x=1", k: :v rescue nil } }
      # rubocop:enable Style/RescueModifier
      before do
        allow(sampler_app).to receive(:response).and_raise(ArgumentError, 'msg')
      end

      include_examples 'saving events'
      context 'saved event' do
        include_examples 'saved event'
      end

      it 'should reraise exception' do
        expect { get '/' }.to raise_error(ArgumentError).with_message('msg')
      end
    end
  end
end
