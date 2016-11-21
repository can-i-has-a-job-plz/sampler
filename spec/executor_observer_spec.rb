# frozen_string_literal: true
describe Sampler::ExecutorObserver do
  let(:observer) { described_class.new }
  let(:result) {}
  let(:exception) {}
  let(:logger) { Sampler.configuration.logger }
  subject(:action) { -> { observer.update(Time.now.utc, result, exception) } }
  context '#update' do
    context 'when task successful' do
      let(:result) { 'xxx' }
      let(:message) { 'Sampler successfully processed events' }
      it 'should log a success' do
        expect(logger).to receive(:debug).with(message)
        action.call
      end
    end
    context 'when task timed out' do
      let(:exception) { Concurrent::TimeoutError.new }
      let(:message) { 'Sampler timed out while saving events' }
      it 'should log a warning' do
        expect(logger).to receive(:warn).with(message)
        action.call
      end
    end
    context 'when task failed' do
      let(:exception) { ArgumentError.new('msg') }
      let(:message) { 'Sampler got ArgumentError (msg) while saving events' }
      it 'should log a warning' do
        expect(logger).to receive(:warn).with(message)
        action.call
      end
    end
  end
end
