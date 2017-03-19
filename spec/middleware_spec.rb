# frozen_string_literal: true

describe Sampler::Middleware, type: :rack_request do
  let(:sampler_app) { RackRequestHelper::SamplerApp.new }
  let(:env) { Rack::MockRequest.env_for('/some_path', input: 'whatever') }

  before do
    allow(RackRequestHelper::SamplerApp)
      .to receive(:new).and_return(sampler_app)
  end

  shared_context 'passed env' do
    it 'should not be modified' do
      expect(sampler_app).to receive(:call).with(env)
      action.call
    end

    context 'rack.input' do
      it 'should not be modified' do
        action.call
        env['rack.input'].rewind
        expect(env['rack.input'].read).to eql('whatever')
      end
    end
  end

  shared_context 'response' do |raises|
    it 'should not be modified', unless: raises do
      expect(app.call(env)).to eql([201, { 'Header' => 'Value' }, 'whatever'])
    end
    it 'should raise original exception', if: raises do
      expect { app.call(env) }
        .to raise_error(error.class).with_message(error.message)
    end
  end

  context 'when app returns a response' do
    let(:action) { -> { app.call(env.dup) } }
    include_context 'passed env'
    include_context 'response', false
  end

  context 'when app raises' do
    let(:action) do
      -> { app.call(env.dup) rescue nil } # rubocop:disable Style/RescueModifier
    end
    let(:error) { RuntimeError.new('oops') }
    before { allow(sampler_app).to receive(:call).and_raise(error) }
    include_context 'passed env'
    include_context 'response', true
  end
end
