# frozen_string_literal: true
describe Sampler::EventProcessor do
  let(:event_processor) { described_class.new }
  context '#events' do
    subject(:events) { event_processor.events }
    let(:events_lock) { event_processor.instance_variable_get(:@events_lock) }

    it 'should be a Concurrent::Map' do
      should be_a(Concurrent::Map)
    end
    it 'should be empty Concurrent::Map' do
      should be_empty
    end
    it 'should have Concurrent::Array as default value' do
      expect(events[:whatever]).to be_a(Concurrent::Array)
    end
    it 'should have Concurrent::Array assigned to the key, not just returned' do
      expect { events[:whatever] << 0 }.to change { events[:whatever] }.to([0])
    end
    it 'should take read lock on event addition' do
      expect(events_lock).to receive(:acquire_read_lock).ordered
      expect(events[:whatever]).to receive(:<<).ordered
      expect(events_lock).to receive(:release_read_lock).ordered
      event_processor << Sampler::Event.new(:whatever)
    end
  end
end
