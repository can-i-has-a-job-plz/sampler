# frozen_string_literal: true
describe Sampler::EventProcessor do
  let(:event_processor) { described_class.new }
  context '#events' do
    subject(:events) { event_processor.events }
    let(:events_lock) { event_processor.instance_variable_get(:@events_lock) }

    it 'should be a Concurrent::Map' do
      should be_a(Concurrent::Map)
    end
    it 'should be empty Concurrent::Map' do
      should be_empty
    end
    it 'should have Concurrent::Array as default value' do
      expect(events[:whatever]).to be_a(Concurrent::Array)
    end
    it 'should have Concurrent::Array assigned to the key, not just returned' do
      expect { events[:whatever] << 0 }.to change { events[:whatever] }.to([0])
    end
    it 'should take read lock on event addition' do
      expect(events_lock).to receive(:acquire_read_lock).ordered
      expect(events[:whatever]).to receive(:<<).ordered
      expect(events_lock).to receive(:release_read_lock).ordered
      event_processor << Sampler::Event.new(:whatever)
    end
  end

  context '#start' do
    subject(:action) { -> { event_processor.start } }
    let(:fake_executor) { Concurrent::TimerTask.new {} }
    let(:interval) { 123 }
    before { Sampler.configuration.interval = interval }
    context 'when executor is nil' do
      before do
        event_processor.instance_variable_set(:@executor, nil)
        allow(Concurrent::TimerTask).to receive(:new).and_return(fake_executor)
      end

      it 'should create executor with proper options' do
        expect(Concurrent::TimerTask)
          .to receive(:new).with(execution_interval: interval,
                                 timeout_interval: interval,
                                 run_now: true).and_return(fake_executor)
        action.call
      end
      it 'should set executor' do
        should change { event_processor.instance_variable_get(:@executor) }
          .to(fake_executor)
      end
      it 'should return true' do
        expect(action.call).to eq(true)
      end
    end
    context 'when executor is not nil' do
      before do
        event_processor.instance_variable_set(:@executor, fake_executor)
      end
      it 'should not change executor' do
        should_not change { event_processor.instance_variable_get(:@executor) }
      end
      it 'should return true' do
        expect(action.call).to be(true)
      end
    end
    context 'created executor' do
      let(:executor) do
        Sampler.configuration.event_processor.instance_variable_get(:@executor)
      end
      it 'should run #process in the block' do
        expect(Sampler.configuration.event_processor).to receive(:process)
        Sampler.configuration.event_processor.start
        executor.execute
        sleep 0.1
      end
    end
  end

  context '#stop' do
    subject(:action) { -> { event_processor.stop } }
    let(:fake_executor) { Concurrent::TimerTask.new {} }
    let(:get_executor) do
      -> { event_processor.instance_variable_get(:@executor) }
    end
    context 'when executor is nil' do
      before { event_processor.instance_variable_set(:@executor, nil) }
      it 'should not change executor' do
        should_not change { get_executor.call }
      end
      it 'should not raise' do
        should_not raise_error
      end
    end
    context' when executor is not nil' do
      before do
        event_processor.instance_variable_set(:@executor, fake_executor)
      end
      context 'when executor is running' do
        before { allow(fake_executor).to receive(:running?).and_return(true) }
        it 'should shutdown executor and wait for termination for 5 seconds' do
          expect(fake_executor).to receive(:shutdown).ordered
          expect(fake_executor)
            .to receive(:wait_for_termination).with(5).ordered
          action.call
        end
        it 'should set executor to nil' do
          expect(action).to change { get_executor.call }.to(nil)
        end
        it 'should return nil' do
          expect(action.call).to be_nil
        end
      end
    end
    context 'when executor is not running' do
      before { allow(fake_executor).to receive(:running?).and_return(false) }
      it 'should not shutdown executor' do
        expect(fake_executor).not_to receive(:shutdown)
        expect(fake_executor).not_to receive(:wait_for_termination)
        action.call
      end
      it 'should not change executor' do
        expect(action).not_to change { get_executor.call }
      end
      it 'should return nil' do
        expect(action.call).to be_nil
      end
    end
  end
end
