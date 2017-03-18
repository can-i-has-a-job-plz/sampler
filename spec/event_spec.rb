# frozen_string_literal: true

describe Sampler::Event do
  let(:request_body) { 'request_body' }
  let(:env) do
    Rack::MockRequest.env_for('/path?x=y', method: :put, input: request_body)
  end
  let(:request) { ActionDispatch::Request.new(env) }
  subject(:new_event) { described_class.new(request) }

  it { should respond_to(:request) }
  it { should respond_to(:url) }
  it { should respond_to(:request_method) }
  it { should respond_to(:params) }
  it { should respond_to(:request_body) }
  it { should respond_to(:created_at) }
  it { should respond_to(:response) }
  it { should respond_to(:response_body) }
  it { should respond_to(:updated_at) }

  shared_context 'Time.now.utc attribute' do |attr_name|
    let(:time) { Time.now.in_time_zone("Nuku'alofa") }
    subject { event.public_send(attr_name) }

    before { expect(Time).to receive(:now).once.and_return(time) }

    it { should be_instance_of(Time) }
    it { should be_utc }
    it('should be set using Time.now') { should eql(time) }
  end

  context 'after initialization' do
    subject(:event) { new_event }

    it { should_not be_frozen }

    context '#request' do
      it 'should be equal to the passed one' do
        expect(event.request).to equal(request)
      end
      it { expect(event.request).not_to be_frozen }
    end

    shared_examples 'attribute from request' do |attr|
      context "##{attr}" do
        subject { event.public_send(attr) }
        it "should be eql to the request.#{attr}" do
          should eql(request.public_send(attr))
        end
        it { should be_frozen }
      end
    end

    include_examples 'attribute from request', 'url'
    include_examples 'attribute from request', 'request_method' do
      context 'when request#method differs from #request_method' do
        before { request.instance_variable_set(:@request_method, 'DELETE') }
        it { expect(request.request_method).not_to eql(request.method) }
        it { expect(event.request_method).to eql(request.request_method) }
      end
    end
    include_examples 'attribute from request', 'params'

    context '#request_body' do
      it 'should be eql to the request.body.read' do
        expect(event.request_body).to eql(request.body.read)
      end
      it { expect(event.request_body).to be_frozen }
    end

    context '#created_at' do
      it_behaves_like 'Time.now.utc attribute', 'created_at'
    end

    context '#response' do
      it { expect(event.response).to be_nil }
    end
    context '#response_body' do
      it { expect(event.response).to be_nil }
    end
    context '#updated_at' do
      it { expect(event.updated_at).to be_nil }
    end

    context 'passed request.body' do
      it 'should be unwinded' do
        expect(request.body.read).to eql(request_body)
      end
    end

    context 'when request changes' do
      subject(:mess_with_request) do
        lambda do
          request.instance_variable_set(:@fullpath, '/fake')
          request.instance_variable_set(:@request_method, 'FAKE')
          request.instance_variable_set(:@env,
                                        Rack::MockRequest.env_for('/fake'))
        end
      end
      context 'request' do
        it { should change(request, :url) }
        it { should change(request, :request_method) }
        it { should change(request, :params) }
        it { should change(request, :body) }
      end

      context 'event' do
        it { should_not change(event, :url) }
        it { should_not change(event, :request_method) }
        it { should_not change(event, :params) }
        it { should_not change(event, :request_body) }
      end
    end
  end

  context 'after finalize' do
    before { new_event }
    let(:finalize) { -> { new_event.finalize(resp) } }
    subject(:event) do
      finalize.call
      new_event
    end

    shared_examples 'common finalize actions' do
      it { should be_frozen }

      shared_examples 'do not change initialized attribute' do |attr_name|
        it "should not change event.#{attr_name}" do
          expect(finalize).not_to change(new_event, attr_name)
        end
      end

      include_examples 'do not change initialized attribute', 'request'
      include_examples 'do not change initialized attribute', 'url'
      include_examples 'do not change initialized attribute', 'request_method'
      include_examples 'do not change initialized attribute', 'params'
      include_examples 'do not change initialized attribute', 'request_body'
      include_examples 'do not change initialized attribute', 'created_at'
    end

    context 'when Exception is passed' do
      let(:resp) { Exception.new('whatever') }

      include_examples 'common finalize actions'

      context '#response' do
        it 'should be the passed Exception' do
          expect(event.response).to equal(resp)
        end
      end
      context '#response_body' do
        it { expect(event.response_body).to be_nil }
      end
      context '#updated_at' do
        it_behaves_like 'Time.now.utc attribute', 'updated_at'
      end
    end

    context 'when proper response is passed' do
      let(:resp) { [201, { 'Header' => 'Value' }, %w(Fake Response)] }

      include_examples 'common finalize actions'

      it 'should return passed response' do
        expect(finalize.call).to eq(resp)
      end

      context '#response' do
        subject(:response) { event.response }
        it { should be_instance_of(ActionDispatch::Response) }
        it 'should be created from passed response' do
          args = [201, hash_including('Header' => 'Value'), %w(Fake Response)]
          expect(ActionDispatch::Response)
            .to receive(:new).once.with(*args).and_call_original
          finalize.call
        end
      end

      context '#response_body' do
        subject(:response_body) { event.response_body }
        it('should match passed response body') { should eql('FakeResponse') }
        it { should be_frozen }
      end

      context 'when response changes' do
        subject(:mess_with_response) { -> { event.response.body = 'fake' } }
        context 'response' do
          it { should change(event.response, :body) }
        end
        context 'event' do
          it { should_not change(event, :response_body) }
        end
      end
    end
  end
end
