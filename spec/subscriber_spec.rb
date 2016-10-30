# frozen_string_literal: true
describe Sampler::Subscriber, subscriber: true do
  subject!(:subscriber) { described_class.new }

  context '::new' do
    it { should_not be_subscribed }
  end

  context 'subscription' do
    let(:delegator) { ->(*) {} }
    let(:subscriber) { Sampler::Subscriber.new }
    subject(:notifier) { ActiveSupport::Notifications }
    before do
      allow(subscriber).to receive(:event_handler).and_return(delegator)
    end
    it 'should be created with proper pattern' do
      should receive(:subscribe).with('request.sampler', anything)
      subscriber.subscribe
    end
    it 'should be created with proper block' do
      should receive(:subscribe).with(anything, delegator)
      subscriber.subscribe
    end
  end

  context 'when subscribed' do
    before { subscriber.subscribe }
    it { should be_subscribed }
    context '#subscribe' do
      subject { -> { subscriber.subscribe } }
      it 'should not add a listener' do
        should_not change { listeners.count }
      end
      it { expect(subject.call).to eq(true) }
    end
    context '#unsubscribe' do
      subject { -> { subscriber.unsubscribe } }
      it 'should remove a listener' do
        should change { listeners.count }.by(-1)
      end
      it { should change(subscriber, :subscribed?).to(false) }
    end
  end

  context 'when not subscribed' do
    before { subscriber.unsubscribe }
    it { should_not be_subscribed }
    context '#subscribe' do
      subject { -> { subscriber.subscribe } }
      it 'should add a listener' do
        should change { listeners.count }.by(1)
      end
      it { should change(subscriber, :subscribed?).to(true) }
      it { expect(subject.call).to eq(true) }
    end
    context '#unsubscribe' do
      it 'should not remove a listener' do
        expect { subscriber.unsubscribe }.not_to change { listeners.count }
      end
    end
  end
end
