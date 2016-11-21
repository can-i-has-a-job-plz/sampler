# frozen_string_literal: true
describe Sampler::Configuration do
  subject(:configuration) { described_class.new }

  context '#probe_class' do
    it { should respond_to(:probe_class) }
    it { should respond_to(:probe_class=) }
    it 'should be nil after initialization' do
      expect(subject.probe_class).to be_nil
    end
  end

  context '#probe_orm' do
    it { should respond_to(:probe_orm) }
    it { should_not respond_to(:probe_orm=) }

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

    context 'when probe_class is assigned' do
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
        # Hiding AR here to check that we work correclty if AR was not required
        before do
          AR = ActiveRecord
          Object.send(:remove_const, 'ActiveRecord')
        end
        after do
          ActiveRecord = AR
          Object.send(:remove_const, 'AR')
        end
        let(:klass) { Class.new(Object) }
        include_examples 'unsupported ORM'
      end
    end
  end

  context '#logger' do
    it { should respond_to(:logger) }
    it { should respond_to(:logger=) }
    it 'should be Logger after initialization' do
      expect(subject.logger).to be_a(Logger)
    end
  end

  context '#event_processor' do
    it { should respond_to(:event_processor) }
    it { should respond_to(:event_processor=) }
    context 'after initialization' do
      it 'shuld be Logger' do
        expect(subject.event_processor).to be_a(Sampler::EventProcessor)
      end
    end
  end

  context '#start' do
    subject(:action) { -> { configuration.start } }
    context 'when not started' do
      before { configuration.instance_variable_set(:@running, false) }
      it 'should set running to true' do
        should change(configuration, :running).to(true)
      end
      it 'should start event_processor' do
        expect(configuration.event_processor).to receive(:start)
        action.call
      end
    end
    context 'when started' do
      before { configuration.instance_variable_set(:@running, true) }
      it 'should not change running' do
        should_not change(configuration, :running)
      end
    end
  end

  context '#stop' do
    subject(:action) { -> { configuration.stop } }
    context 'when started' do
      before { configuration.instance_variable_set(:@running, true) }
      it 'should set running to true' do
        should change(configuration, :running).to(false)
      end
      it 'should stop event_processor' do
        expect(configuration.event_processor).to receive(:stop)
        action.call
      end
    end
    context 'when not started' do
      before { configuration.instance_variable_set(:@running, false) }
      it 'should not change running' do
        should_not change(configuration, :running)
      end
    end
  end

  context '#running' do
    it { should respond_to(:running) }
    it { should_not respond_to(:running=) }
    context 'after initialization' do
      it { expect(subject.running).to be(false) }
    end
  end

  context '#whitelist' do
    let(:action) { -> { subject.whitelist = value } }

    it { should respond_to(:whitelist) }
    it { should respond_to(:whitelist=) }
    it 'should be nil after initialize' do
      expect(subject.whitelist).to be_nil
    end

    context 'when assigning a Regexp' do
      let(:value) { // }
      context 'when list is nil' do
        before { subject.whitelist = nil }
        it 'should assign a value' do
          expect(action).to change(subject, :whitelist).to(value)
        end
      end
      context 'when list is not nil' do
        before { subject.whitelist = /regexp/ }
        it 'should assign a value' do
          expect(action).to change(subject, :whitelist).to(value)
        end
      end
    end

    context 'when assigning a nil' do
      let(:value) {}
      context 'when list is nil' do
        before { subject.whitelist = nil }
        it { expect(action).not_to change(subject, :whitelist) }
      end
      context 'when list is not nil' do
        before { subject.whitelist = /regexp/ }
        it { expect(action).to change(subject, :whitelist).to(nil) }
      end
    end

    context 'when assigning not nil and not a Regexp' do
      let(:value) { 'string' }
      let(:msg) { 'whitelist should be nil or a Regexp' }
      # rubocop:disable Style/RescueModifier
      let(:rescued_action) { -> { action.call rescue nil } }
      # rubocop:enable Style/RescueModifier
      context 'when attribute is nil' do
        before { subject.whitelist = nil }
        it { expect(action).to raise_error(ArgumentError).with_message(msg) }
        it { expect(rescued_action).not_to change(subject, :whitelist) }
      end
      context 'when attribute is not nil' do
        before { subject.whitelist = /regexp/ }
        it { expect(action).to raise_error(ArgumentError).with_message(msg) }
        it { expect(rescued_action).not_to change(subject, :whitelist) }
      end
    end
  end

  context '#blacklist' do
    it { should respond_to(:blacklist) }
    it { should_not respond_to(:blacklist=) }
    it 'should be Set after initialization' do
      expect(subject.blacklist).to be_a(Set)
    end
  end

  context '#tags' do
    it { should respond_to(:tags) }
    it { should_not respond_to(:tags=) }
    context 'after initialization' do
      it { expect(subject.tags).to be_a(HashWithIndifferentAccess) }
      it { expect(subject.tags).to be_empty }
    end
  end

  shared_examples 'should save a tag' do
    it 'should update a new entry in the tags hash' do
      expect(action).to change { subject.tags.key?('name') }.to(true)
    end
    it 'should save a passed Proc' do
      expect(action).to change { subject.tags['name'] }.to(value)
    end
  end

  shared_examples 'should not save a tag' do
    # rubocop:disable Style/RescueModifier
    let(:rescued_action) { -> { action.call rescue nil } }
    # rubocop:enable Style/RescueModifier
    context 'if tag does not exist yet' do
      it { expect(action).to raise_error(ArgumentError).with_message(message) }
      it 'should not save a passed value' do
        expect(rescued_action).not_to change { subject.tags['name'] }
      end
    end
  end

  context '#tag_with' do
    let(:value) { ->(_e) {} }
    let(:action) { -> { subject.tag_with 'name', value } }
    let(:name_message) { 'tag name should be a String or a Symbol' }
    let(:value_message) { 'tag filter should be nil or Proc with arity 1' }

    context 'when filter is a Proc with arity 1' do
      let(:value) { ->(_e) {} }
      include_examples 'should save a tag'
    end

    context 'when filter is nil' do
      let(:value) {}
      context 'if tag does not exist yet' do
        before { subject.tags.delete('name') }
        it 'should not create an entry in tags hash' do
          expect(action).not_to change { subject.tags.key?('name') }
        end
        it 'should return nil' do
          expect(action.call).to be_nil
        end
      end
      context 'if tag already exists' do
        before { subject.tags['name'] = -> {} }
        it 'should delete entry for the tag' do
          expect(action).to change { subject.tags.key?('name') }.to(false)
        end
        it 'should return nil' do
          expect(action.call).to be_nil
        end
      end
    end

    context 'when filter is wrong' do
      let(:message) { value_message }
      context 'Proc with arity 0' do
        let(:value) { -> {} }
        include_examples 'should not save a tag'
      end
      context 'Proc with arity 2' do
        let(:value) { ->(_x, _y) {} }
        include_examples 'should not save a tag'
      end
      context 'not a Proc' do
        let(:value) { 'value' }
        include_examples 'should not save a tag'
      end
    end

    context 'when tag name is a String' do
      let(:action) { -> { subject.tag_with 'name', value } }
      include_examples 'should save a tag'
    end
    context 'when tag name is a Symbol' do
      let(:action) { -> { subject.tag_with :name, value } }
      include_examples 'should save a tag'
    end
    context 'when tag name is not a String and is not a Symbol' do
      let(:action) { -> { subject.tag_with Object.new, value } }
      let(:message) { name_message }
      include_examples 'should not save a tag'
    end
  end

  shared_examples 'positive_integer_attr' do |name, initial|
    context "##{name}" do
      it { should respond_to(name) }
      it "should be set to #{initial.inspect} after initialization" do
        expect(subject.send(name)).to eq(initial)
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

  include_examples 'positive_integer_attr', :max_probes_per_endpoint
  include_examples 'positive_integer_attr', :max_probes_per_hour
  include_examples 'positive_integer_attr', :retention_period
  include_examples 'positive_integer_attr', :interval, 60
end
