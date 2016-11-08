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
      context 'when probe_class is ORM class itself' do
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
    let(:value) { ->(_e) {} }
    let(:action) { -> { subject.tag_with 'name', value } }
    let(:message) { 'filter should be a Proc' }
    context 'after initialization' do
      it { expect(subject.tags).to be_a(HashWithIndifferentAccess) }
      it { expect(subject.tags).to be_empty }
    end
    it 'should create a new entry in the tags hash' do
      expect(action).to change { subject.tags.key?('name') }.to(true)
    end
    context 'created entry for a tag' do
      before { action.call }
      it 'should be a FilterSet' do
        expect(subject.tags['name']).to be_a(Sampler::FilterSet)
      end
      it 'should add filter to the tag entry' do
        expect(subject.tags['name']).to include(value)
      end
    end
    context 'when filter is a String' do
      let(:value) { 'value' }
      it { expect(action).to raise_error(ArgumentError).with_message(message) }
    end
    context 'when filter is a Regexp' do
      let(:value) { /regexp/ }
      it { expect(action).to raise_error(ArgumentError).with_message(message) }
    end
    context 'when tag name is a String' do
      let(:action) { -> { subject.tag_with 'name', value } }
      it { expect(action).not_to raise_error }
    end
    context 'when tag name is a Symbol' do
      let(:action) { -> { subject.tag_with :name, value } }
      it { expect(action).not_to raise_error }
    end
  end

  shared_examples :positive_integer_attr do |name|
    context "##{name}" do
      it { should respond_to(name) }
      it 'should be nil after initialization' do
        expect(subject.send(name)).to be_nil
      end
    end

    context "##{name}=" do
      it { should respond_to("#{name}=") }
      context 'with value' do
        let(:error_message) { "#{name} should be positive integer" }
        subject(:set) { -> { configuration.send("#{name}=", value) } }
        context 'when positive Integer' do
          let(:value) { 100 }
          it { should change(configuration, name).to(value) }
        end
        context 'when nil' do
          before { configuration.send("#{name}=", 1) }
          let(:value) { nil }
          it { should change(configuration, name).to(value) }
        end
        context 'when zero' do
          let(:value) { 0 }
          it { should raise_error(ArgumentError).with_message(error_message) }
        end
        context 'when negative Integer' do
          let(:value) { -1 }
          it { should raise_error(ArgumentError).with_message(error_message) }
        end
        context 'when non-Integer' do
          let(:value) { [] }
          it { should raise_error(ArgumentError).with_message(error_message) }
        end
      end
    end
  end

  include_examples :positive_integer_attr, :max_probes_per_hour
end
