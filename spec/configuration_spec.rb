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
end
