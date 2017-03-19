# frozen_string_literal: true

describe Sampler::Configuration do
  subject(:configuration) { described_class.new }

  context 'after initialization' do
    it { should_not be_running }
    context '#whitelist' do
      it { expect(configuration.whitelist).not_to be_nil }
      it { expect(subject.whitelist).to respond_to(:match?) }
      it 'should not match anything' do
        # FIXME: how we can test it?
        expect(subject.whitelist).not_to match('')
      end
    end
  end

  context '#start' do
    subject { -> { configuration.start } }
    context 'when is not running' do
      it { should change(configuration, :running?).to(true) }
    end
    context 'when is running' do
      before { configuration.start }
      it { should_not change(configuration, :running?) }
    end
  end

  context '#stop' do
    subject { -> { configuration.stop } }
    context 'when is not running' do
      it { should_not change(configuration, :running?) }
    end
    context 'when is running' do
      before { configuration.start }
      it { should change(configuration, :running?).to(false) }
    end
  end

  context '#whitelist=' do
    let(:object) { Object.new }
    subject(:action) { -> { configuration.whitelist = object } }
    let(:rescued_action) do
      -> { action.call rescue nil } # rubocop:disable Style/RescueModifier
    end

    context 'when nil' do
      let(:object) { nil }
      it { should raise_error(ArgumentError) }
      it { expect(rescued_action).not_to change(configuration, :whitelist) }
    end
    context 'when respond_to?(:match?)' do
      before do
        allow(object).to receive(:respond_to?).and_return(false)
        allow(object).to receive(:respond_to?).with(:match?).and_return(true)
      end
      it { should_not raise_error }
      it { should change(configuration, :whitelist).to(object) }
    end
    context 'when not respond_to?(:match?)' do
      it { should raise_error(ArgumentError) }
      it { expect(rescued_action).not_to change(configuration, :whitelist) }
    end
  end

  context '#sampled?' do
    let(:endpoint) { '/endpoint' }

    [true, false].each do |whitelisted|
      description = "when endpoint #{'not ' unless whitelisted}whitelisted"

      context description do
        let(:should_be_sampled) { whitelisted }
        before { configuration.whitelist = whitelisted ? // : /\a\Z/ }
        it { expect(configuration.sampled?(endpoint)).to be(should_be_sampled) }
      end
    end
  end
end
