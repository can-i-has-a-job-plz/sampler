# frozen_string_literal: true

describe Sampler::Middleware, type: :rack_request do
  shared_context 'passed env' do
    before do
      allow(Sampler::Event).to receive(:new).and_wrap_original do |m, ep, req|
        # messing with received request
        req.env['rack.input'].reopen
        req.env['rack.input'].write('fake')
        req.env['rack.input'].rewind
        req.env['rack.fake'] = 'fake'
        m.call(ep, req)
      end
    end

    it 'should not be modified' do
      expect(sampler_app).to receive(:call).with(env)
      action.call
    end

    context 'rack.input' do
      it 'should not be modified' do
        skip 'do we really care about it?'
        action.call
        env['rack.input'].rewind
        expect(env['rack.input'].read).to eql('whatever')
      end
    end
  end

  shared_context 'response' do |raises|
    before unless: raises do
      event = instance_double(Sampler::Event)
      allow(Sampler::Event).to receive(:new).and_return(event)
      allow(event).to receive(:finalize) do |resp|
        # messing with received response
        resp[0] = 502
        resp[1] = { 'Fake' => 'Header' }
        resp[2] = 'fake body'
      end
    end

    it 'should not be modified', unless: raises do
      expect(app.call(env)).to eql([201, { 'Header' => 'Value' }, 'whatever'])
    end
    it 'should raise original exception', if: raises do
      expect { app.call(env) }
        .to raise_error(response.class).with_message(response.message)
    end
  end

  shared_context 'creating event' do |running|
    let(:event) { Sampler::Event.new(endpoint, request) }
    let(:request) { ActionDispatch::Request.new(env) }

    context 'Event.new' do
      before { allow(event).to receive(:finalize) }

      it 'should be called once with proper arguments', if: running do
        expect(ActionDispatch::Request)
          .to receive(:new).with(env).once.and_return(request)
        expect(Sampler::Event)
          .to receive(:new).with(endpoint, request).once.and_return(event)
        action.call
      end

      it 'should not be called', unless: running do
        expect(Sampler::Event).not_to receive(:new)
        action.call
      end
    end

    context 'Event#finalize', if: running do
      before { allow(Sampler::Event).to receive(:new).and_return(event) }
      it 'should be called on created event with proper argument' do
        expect(sampler_app).to receive(:call).and_return(response)
        expect(event).to receive(:finalize).with(response)
        action.call
      end
    end
  end

  shared_examples 'test all' do |raises|
    let(:sampler_app) { RackRequestHelper::SamplerApp.new }
    let(:router) { Rails.application.routes.router }

    before do
      allow(RackRequestHelper::SamplerApp)
        .to receive(:new).and_return(sampler_app)
    end

    cases = (0..4).to_a.product([true, false], [true, false])
    cases.each do |found, running, sampled|
      should_create = running && sampled

      description = 'when route is '
      description += case found
                     when 0 then 'not found '
                     when 1 then 'raised during resolution '
                     when 2 then 'found '
                     when 3
                       'multiple found and first does not match constraint '
                     when 4 then 'found and goes to mounted app '
                     end
      description += "and Sampler is #{'not ' unless running}running "
      description += "and #{'not ' unless sampled}sampled"

      context description do
        let(:path) do
          case found
          when 0 then '/does_not_exist'
          when 1, 2 then '/authors/123'
          when 3 then '/books/whatever'
          when 4 then '/loop/loop/authors/123'
          end
        end
        let(:endpoint) do
          case found
          when 0 then 'not#found'
          when 1 then 'resolve#error'
          when 2 then '/authors/:id(.:format)'
          when 3 then '/books/*whatever(.:format)'
          when 4 then '/loop/loop/authors/:id(.:format)'
          end
        end
        let(:env) { Rack::MockRequest.env_for(path, input: 'whatever') }

        before do
          allow(router).to receive(:find_routes).and_raise if found == 1
          running ? Sampler.start : Sampler.stop
          allow(Sampler.configuration)
            .to receive(:sampled?).with(anything).and_return(sampled)
        end

        include_context 'passed env'
        include_context 'response', raises
        include_context 'creating event', should_create
      end
    end
  end

  context 'when app returns a response' do
    let(:action) { -> { app.call(env.dup) } }
    let(:response) { [502, { 'H' => 'V' }, 'my body'] }
    include_examples 'test all', false
  end

  context 'when app raises' do
    let(:action) do
      -> { app.call(env.dup) rescue nil } # rubocop:disable Style/RescueModifier
    end
    let(:response) { RuntimeError.new('oops') }
    before { allow(sampler_app).to receive(:call).and_raise(response) }
    include_context 'test all', true
  end
end
