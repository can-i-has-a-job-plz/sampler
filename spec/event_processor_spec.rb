# frozen_string_literal: true
describe Sampler::EventProcessor do
  context '#events' do
    subject(:events) { described_class.new.events }
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
  end
end
