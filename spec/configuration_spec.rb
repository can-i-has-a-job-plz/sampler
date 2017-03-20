# frozen_string_literal: true

describe Sampler::Configuration do
  subject(:configuration) { described_class.new }
  let(:rescued_action) do
    -> { action.call rescue nil } # rubocop:disable Style/RescueModifier
  end

  it { should delegate_method(:events).to(:storage) }

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
    context '#blacklist' do
      it { expect(configuration.blacklist).not_to be_nil }
      it { expect(subject.blacklist).to respond_to(:include?) }
      it { expect(subject.blacklist).to respond_to(:<<) }
      it { expect(subject.blacklist).to be_empty }
    end
    context '#tags' do
      subject(:tags) { configuration.tags }
      it { should_not be_nil }
      it { should respond_to(:each_pair) }
      it { should respond_to(:[]=) }
      it { should be_empty }
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
    let(:blacklist) { configuration.blacklist }

    [true, false].product([true, false]).each do |whitelisted, blacklisted|
      description = "when endpoint #{'not ' unless whitelisted}whitelisted "
      description += "and #{'not ' unless blacklisted}blacklisted"

      context description do
        let(:should_be_sampled) { whitelisted && !blacklisted }
        before do
          configuration.whitelist = whitelisted ? // : /\a\Z/
          blacklisted ? blacklist << endpoint : blacklist.clear
        end
        it { expect(configuration.sampled?(endpoint)).to be(should_be_sampled) }
      end
    end
  end

  context '#logger' do
    it 'should be Logger after initialization' do
      expect(subject.logger).to be_a(Logger)
    end
    it { should respond_to(:logger=) }
  end

  context '#tag_with' do
    subject(:action) { -> { configuration.tag_with('name', filter) } }
    let(:error_message) { 'tag filter should be nil or callable with arity 1' }
    let(:tags) { configuration.tags }

    shared_examples '#tag_with with callable & arity' do |callable, arity|
      description = 'when filter is '
      description += "#{'not ' unless callable}callable "
      description += if arity then "with arity #{arity}"
                     else 'and does not respond_to?(:arity)'
                     end
      context description do
        let(:filter) do
          obj = Object.new
          allow(obj).to receive(:respond_to?).and_return(true)
          if arity
            allow(obj).to receive(:arity).and_return(arity)
          else
            allow(obj).to receive(:respond_to?).with(:arity).and_return(false)
          end
          return obj if callable
          allow(obj).to receive(:respond_to?).with(:call).and_return(false)
          obj
        end
        if callable && arity.equal?(1)
          it { should change { tags.key?('name') }.to(true) }
          it { should change { tags['name'] }.to(filter) }
        else
          it do
            should raise_error(ArgumentError).with_message(error_message)
          end
          it { expect(rescued_action).not_to change(configuration, :tags) }
        end
      end
    end

    [true, false].product([false, *(0..2)]).each do |callable, arity|
      include_examples '#tag_with with callable & arity', callable, arity
    end

    context 'when filter is nil' do
      let(:filter) { nil }
      context 'when tag does not exist' do
        before { tags.delete('name') }
        it { should_not change(configuration, :tags) }
      end
      context 'when tag already exists' do
        before { configuration.tag_with('name', ->(x) {}) }
        it 'should remove tag' do
          should change { tags.key?('name') }.to(false)
        end
      end
    end
  end

  context '#storage' do
    it { expect(configuration.storage).to be_instance_of(Sampler::Storage) }
  end
end
