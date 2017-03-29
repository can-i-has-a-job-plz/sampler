# frozen_string_literal: true

describe Sampler::Storage do
  let(:storage) { described_class.new }

  context '<<' do
    subject(:action) { -> { events.each { |e| storage << e } } }

    shared_examples 'should not save event' do
      it { should_not change(storage, :events) }
      it 'should log a warning' do
        expect(Sampler.logger).to receive(:warn).with(message)
        action.call
      end
    end

    context 'when non-Event is passed' do
      let(:message) { "Got #{events.first} instead of Event" }
      let(:events) { [Object.new] }
      include_examples 'should not save event'
    end
    context 'when Event is passed' do
      context 'with nil endpoint' do
        let(:message) { "Got event with nil endpoint #{events.first}" }
        let(:events) { [create(:event, endpoint: nil)] }
        include_examples 'should not save event'
      end
      context 'with non-nil endpoint' do
        let(:events) { [create(:event, endpoint: 'endpoint')] }
        it { should change(storage, :events).to(events) }
      end
    end

    context 'when multiple Events are passed' do
      let(:events) { create_list(:event, 3) }

      it 'should return them all' do
        should change(storage, :events).to(match_array(events))
      end
    end
  end

  context '#events' do
    let(:events) { create_list(:event, 5) }
    before { events.each { |e| storage << e } }
    it 'should clear event storage' do
      expect { storage.events }.to change(storage, :events).from(events).to([])
    end
  end
end
