# frozen_string_literal: true
describe Sampler::Configuration do
  subject(:configuration) { described_class.new }

  context '#probe_class' do
    it { should respond_to(:probe_class) }
    it { should respond_to(:probe_class=) }
    it 'should be nil after initialization' do
      expect(subject.probe_class).to be_nil
    end

    shared_examples 'unsupported ORM' do
      it { should raise_error(ArgumentError).with_message('Unsupported ORM') }
      it { expect(rescue_action).not_to change(configuration, :probe_orm) }
      it { expect(rescue_action).not_to change(configuration, :probe_class) }
    end

    shared_examples 'supported ORM' do
      let(:klass) { Class.new(superklass) }
      it { should change(configuration, :probe_orm).to(probe_orm) }
      it { should change(configuration, :probe_class).to(klass) }
      context 'when probe_class is ActiveRecord::Base itself' do
        let(:klass) { superklass }
        include_examples 'unsupported ORM'
      end
    end

    context 'when assigned' do
      subject(:action) { -> { configuration.probe_class = klass } }
      # rubocop:disable Style/RescueModifier
      let(:rescue_action) { -> { action.call rescue nil } }
      # rubocop:enable Style/RescueModifier
      context 'when probe_class is ActiveRecord model' do
        let(:superklass) { ActiveRecord::Base }
        let(:probe_orm) { :active_record }
        include_examples 'supported ORM'
      end
      context 'when probe_class is NilClass subclass' do
        let(:superklass) { NilClass }
        let(:probe_orm) { :nil_record }
        include_examples 'supported ORM'
      end
      context 'when ORM of probe_class cannot be determined' do
        let(:klass) { Class.new(Object) }
        include_examples 'unsupported ORM'
      end
    end

    shared_examples 'somelist' do
      it { should respond_to(somelist) }
      it 'should be FilterSet after initialize' do
        expect(subject.send(somelist)).to be_a(Sampler::FilterSet)
      end
      it 'should be empty after initialize' do
        expect(subject.send(somelist)).to be_empty
      end
    end

    context 'whitelist' do
      let(:somelist) { :whitelist }
      include_examples 'somelist'
    end
    context 'black' do
      let(:somelist) { :blacklist }
      include_examples 'somelist'
    end
  end

  context '#tag_with' do
    let(:action) { -> { subject.tag_with 'name', 'value' } }
    it 'should create a new entry in the tags hash' do
      expect(action).to change { subject.tags.key?('name') }.to(true)
    end
    context 'created entry for a tag' do
      before { action.call }
      it 'should be a FilterSet' do
        expect(subject.tags['name']).to be_a(Sampler::FilterSet)
      end
      it 'should add filter to the tag entry' do
        expect(subject.tags['name']).to include('value')
      end
    end
  end

  context '#max_probes_per hour' do
    it { should respond_to(:max_probes_per_hour) }
    it 'should be nil after initialization' do
      expect(subject.max_probes_per_hour).to be_nil
    end
  end

  context '#max_probes_per_hour=' do
    it { should respond_to(:max_probes_per_hour=) }
    context 'with value' do
      let(:error_message) { 'We need positive integer here' }
      subject(:set) { -> { configuration.max_probes_per_hour = value } }
      context 'when positive Integer' do
        let(:value) { 100 }
        it { should change(configuration, :max_probes_per_hour).to(value) }
      end
      context 'when zero' do
        let(:value) { 0 }
        it { should raise_error(ArgumentError).with_message(error_message) }
      end
      context 'when negative Integer' do
        let(:value) { -1 }
        it { should raise_error(ArgumentError).with_message(error_message) }
      end
      context 'when nil' do
        before { configuration.max_probes_per_hour = 1 }
        let(:value) { nil }
        it { should change(configuration, :max_probes_per_hour).to(value) }
      end
      context 'when not Integer' do
        let(:value) { Object.new }
        it { should raise_error(ArgumentError).with_message(error_message) }
      end
    end
  end

  context '#max_probes_per endpoint' do
    it { should respond_to(:max_probes_per_endpoint) }
    it 'should be nil after initialization' do
      expect(subject.max_probes_per_endpoint).to be_nil
    end
  end

  context '#max_probes_per_endpoint=' do
    it { should respond_to(:max_probes_per_endpoint=) }
    context 'with value' do
      let(:error_message) { 'We need positive integer here' }
      subject(:set) { -> { configuration.max_probes_per_endpoint = value } }
      context 'when positive Integer' do
        let(:value) { 100 }
        it { should change(configuration, :max_probes_per_endpoint).to(value) }
      end
      context 'when zero' do
        let(:value) { 0 }
        it { should raise_error(ArgumentError).with_message(error_message) }
      end
      context 'when negative Integer' do
        let(:value) { -1 }
        it { should raise_error(ArgumentError).with_message(error_message) }
      end
      context 'when nil' do
        before { configuration.max_probes_per_endpoint = 1 }
        let(:value) { nil }
        it { should change(configuration, :max_probes_per_endpoint).to(value) }
      end
      context 'when not Integer' do
        let(:value) { Object.new }
        it { should raise_error(ArgumentError).with_message(error_message) }
      end
    end
  end

  context '#retention_period' do
    it { should respond_to(:retention_period) }
    it 'should be nil after initialization' do
      expect(subject.retention_period).to be_nil
    end
  end

  context '#retention_period=' do
    it { should respond_to(:retention_period=) }
    context 'with value' do
      let(:error_message) { 'We need positive integer here' }
      subject(:set) { -> { configuration.retention_period = value } }
      context 'when positive Integer' do
        let(:value) { 100 }
        it { should change(configuration, :retention_period).to(value) }
      end
      context 'when zero' do
        let(:value) { 0 }
        it { should raise_error(ArgumentError).with_message(error_message) }
      end
      context 'when negative Integer' do
        let(:value) { -1 }
        it { should raise_error(ArgumentError).with_message(error_message) }
      end
      context 'when nil' do
        before { configuration.retention_period = 1 }
        let(:value) { nil }
        it { should change(configuration, :retention_period).to(value) }
      end
      context 'when not Integer' do
        let(:value) { Object.new }
        it { should raise_error(ArgumentError).with_message(error_message) }
      end
    end
  end
end
