# frozen_string_literal: true
describe Sampler::EventProcessor, type: :request do
  def rand_string
    Array.new(rand(2..5)) { ('a'..'z').to_a.sample }.join
  end

  def make_request(path)
    params = Array.new(rand(2..5)) { [rand_string, rand_string] }.to_h
    params.each_key do |k|
      Sampler.configuration.tag_with k, ->(e) { e.params.key?(k) }
    end
    get path, params: params
  end

  context '#process' do
    # TODO: check that we don't block adding events
    let!(:event_processor) { described_class.new }
    subject(:action) { -> { event_processor.process } }
    let(:path) { '/authors/new' }
    let(:endpoint) { "#{path}(.:format)" }
    let(:config) { Sampler.configuration }
    let(:probe_class) { config.probe_class }
    let(:probe_count) { 3 }
    let(:logger) { config.logger }
    let(:events) { event_processor.events }
    let(:events_lock) { event_processor.instance_variable_get(:@events_lock) }
    let(:base_events) { events[endpoint].dup }
    before do
      allow(described_class).to receive(:new).and_return(event_processor)
      Sampler.start
      config.probe_class = Sample
      config.whitelist = %r{/authors}
      probe_count.times { make_request path }
    end

    shared_examples 'should correctly save all events' do
      # TODO: report something meaningful if expectation failed
      it 'should have all expected events properly saved' do
        expect(expected_events).not_to be_blank
        action.call
        expected_events.each do |e|
          # FIXME: can match multiple events with different params/tags
          event = probe_class.find_by(e.to_h.except(:params, :tags))
          expect(event).not_to be_nil
          expect(event.tags).to match_array(e.tags)
          expect(event.params).to eql(e.params)
        end
      end
    end

    context 'basic queue processing' do
      let(:expected_events) { base_events }
      it 'should save all events in queue' do
        should change(Sample, :count).by(probe_count)
      end
      it 'should remove processed events from queue' do
        should change(events[endpoint], :size).to(0)
      end
      it 'should not create or remove a queue' do
        should_not change(events, :keys)
      end
      include_examples 'should correctly save all events'
    end

    context 'when new events are added during processing' do
      let(:probe) { Object.new }
      let(:done) { false }
      let(:expected_events) { base_events - [probe] }
      before do
        done = false
        allow(Sample).to receive(:new).and_wrap_original do |m, *args|
          events[endpoint] << probe unless done
          done = true
          m.call(*args)
        end
      end
      it 'should remove only old probes from queue' do
        should change { events[endpoint] }.to([probe])
      end
      include_examples 'should correctly save all events'
    end

    context 'when there is an invalid event during processing' do
      before do
        events[endpoint][-1].endpoint = nil
        events[endpoint][-1].url = nil
      end
      let(:expected_events) { base_events - [events[endpoint][-1]] }
      let(:message) do
        "Got invalid sample: Endpoint can't be blank, Url can't be blank"
      end
      it 'should log a warning' do
        expect(logger).to receive(:warn).with(message).once
        action.call
      end
      it 'should save other events' do
        should change(Sample, :count).by(probe_count - 1)
      end
      include_examples 'should correctly save all events'
    end

    context 'when there is multiple queues' do
      let(:expected_events) { base_events + events['/authors'] }
      before { probe_count.times { make_request '/authors' } }
      it 'should save events from all queues' do
        should change(Sample, :count).by(probe_count * 2)
      end
      it 'should not create or remove queues' do
        should_not change(events, :keys)
      end
      include_examples 'should correctly save all events'
    end

    context 'when #saving_events raises' do
      # rubocop:disable Style/RescueModifier
      subject(:action) { -> { event_processor.process rescue nil } }
      # rubocop:enable Style/RescueModifier
      let(:tbs) { event_processor.instance_variable_get(:@to_be_saved) }
      before { allow(event_processor).to receive(:save_events).and_raise }
      it 'should retain events in @to_be_saved' do
        expected = events[endpoint].dup
        should change { tbs[endpoint] }.to(expected)
      end
    end

    context 'when @to_be_saved is not empty' do
      let(:tbs) { event_processor.instance_variable_get(:@to_be_saved) }
      let(:expected_events) { [] }
      before do
        tbs[endpoint] = events[endpoint].dup
        expected_events.concat(tbs[endpoint].dup)
        events[endpoint].clear
        probe_count.times { make_request path }
        expected_events.concat(events[endpoint].dup)
      end
      include_examples 'should correctly save all events'
    end

    context 'when there is empty queue' do
      before { events[:empty] = [] }
      it 'should delete it' do
        should change(events, :keys).to([endpoint])
      end
    end

    it 'should delete empty queues holding write lock' do
      expect(events_lock).to receive(:acquire_write_lock).ordered
      expect(events[endpoint]).to receive(:empty?).ordered
      expect(events_lock).to receive(:release_write_lock).ordered
      subject.call
    end
    it 'should release lock before processing non-empty queues' do
      expect(events_lock).to receive(:acquire_write_lock).ordered
      expect(events_lock).to receive(:release_write_lock).ordered
      expect(event_processor).to receive(:fill_events).ordered
      subject.call
    end

    context 'when event count in queue greater that max_probes_per_endpoint' do
      let(:count) { probe_count - 1 }
      let(:expected_events) { events[endpoint].last(count) }
      before { config.max_probes_per_endpoint = count }
      it 'should save only max_probes_per_endpoint samples' do
        should change(Sample, :count).by(count)
      end
      include_examples 'should correctly save all events'
    end

    context 'retention' do
      before { action.call }
      context '#max_probes_per_endpoint' do
        context 'when nil' do
          before { config.max_probes_per_endpoint = nil }
          it 'should not delete any samples' do
            should_not change(Sample, :count)
          end
        end
        context 'when not nil' do
          let(:count) { probe_count - 1 }
          let(:expected_samples) do
            Sample.where(endpoint: endpoint).order(:created_at).last(count)
          end
          before { config.max_probes_per_endpoint = count }
          it 'should retain allowed sample count' do
            should change(Sample.where(endpoint: endpoint), :count).to(count)
          end
          it 'should remove proper samples' do
            action.call
            expect(Sample.where(endpoint: endpoint)).to eq(expected_samples)
          end
        end
      end
    end
  end
end
