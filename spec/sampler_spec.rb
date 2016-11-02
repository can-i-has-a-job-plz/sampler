# frozen_string_literal: true
describe Sampler, subscriber: true do
  subject { Sampler }
  before do |example|
    next if example.metadata[:do_not_init]
    Sampler.configuration.probe_class = Class.new(ActiveRecord::Base)
  end

  it 'has a version number' do
    expect(Sampler::VERSION).not_to be nil
  end

  context '.configuration', do_not_init: true do
    subject(:configuration) { Sampler.configuration }
    it 'should be Sampler::Configuration instance' do
      should be_a(Sampler::Configuration)
    end
  end

  context '.configure', do_not_init: true do
    subject(:configuration) { Sampler.configuration }
    it 'should invoke the block and yield configuration' do
      should receive(:attribute)
      Sampler.configure(&:attribute)
    end
  end

  shared_examples 'should not change subscriber' do
    it 'should not create a new Subscriber' do
      expect(Sampler::Subscriber).not_to receive(:new)
      subject.call
    end
    it { should_not change(Sampler, :subscriber) }
  end

  context 'when not started' do
    let(:subscriber) { Sampler::Subscriber.new }
    before do
      allow(Sampler::Subscriber).to receive(:new).and_return(subscriber)
    end
    context '.start' do
      subject { -> { Sampler.start } }
      it 'should change #subscriber from nil to subscriber' do
        should change(Sampler, :subscriber).from(nil).to(subscriber)
      end
    end
    context '.stop' do
      subject { -> { Sampler.stop } }
      include_examples 'should not change subscriber'
      it { should_not raise_error }
    end
  end

  context 'when started' do
    before { Sampler.start }
    context '.start' do
      subject { -> { Sampler.start } }
      include_examples 'should not change subscriber'
    end
    context '.stop' do
      subject { -> { Sampler.stop } }
      include_examples 'should not change subscriber'
      it { should change(Sampler.subscriber, :subscribed?).to(false) }
    end
  end

  context 'when stopped' do
    before { Sampler.start && Sampler.stop }
    context '.start' do
      subject { -> { Sampler.start } }
      include_examples 'should not change subscriber'
      it { should change(Sampler.subscriber, :subscribed?).to(true) }
    end
    context '.stop' do
      subject { -> { Sampler.stop } }
      include_examples 'should not change subscriber'
      it { should_not raise_error }
    end
  end
end
