# frozen_string_literal: true

describe Sampler::Configuration do
  subject(:configuration) { described_class.new }

  context 'after initialization' do
    it { should_not be_running }
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
end
