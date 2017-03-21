# frozen_string_literal: true

describe Sampler::ExecutorObserver do
  let(:observer) { described_class.new }
  let(:result) {}
  let(:exception) {}
  subject(:action) { -> { observer.update(Time.now.utc, result, exception) } }

  context '#update' do
    context 'when task successful' do
      let(:result) { 3 }
      it 'should log a success' do
        message = 'Sampler successfully processed 3 events'
        expect(Sampler.logger).to receive(:debug).with(message)
        action.call
      end
    end

    context 'when task timed out' do
      let(:exception) { Concurrent::TimeoutError.new }
      it 'should log a warning' do
        message = 'Sampler timed out while saving events'
        expect(Sampler.logger).to receive(:warn).with(message)
        action.call
      end
    end

    context 'when task failed' do
      let(:exception) { ArgumentError.new('msg') }
      it 'should log a warning' do
        message = 'Sampler got ArgumentError (msg) while saving events'
        expect(Sampler.logger).to receive(:warn).with(message)
        action.call
      end
    end
  end
end
