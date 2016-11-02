# frozen_string_literal: true
describe Sampler::Subscriber, subscriber: true do
  before do |example|
    next if example.metadata[:nil_probe_class]
    Sampler.configuration.probe_class = Class.new(NilClass)
  end
  subject(:subscriber) { described_class.new }

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

  shared_examples 'call save_to' do |wl, bl|
    context "when whitelisted: #{wl}, blacklisted: #{bl}", wl: wl, bl: bl do
      it 'should not look up method for saving event' do
        expect(Sampler.configuration).not_to receive(:probe_orm)
        expect(subscriber).not_to receive(:method).with(save_method_name)
        get '/'
      end
      context 'created event' do
        let(:args) { [Time.now.utc, Time.now.utc + 1, 'name', 'payload'] }
        # rubocop:disable Metrics/LineLength
        # Looks fugly with any line breaks
        it 'should receive arguments from notification', args_check: true do
          expect(Sampler::Event).to receive(:new).once.with('request.sampler', *args).and_return(event)
          ActiveSupport::Notifications.notifier.publish('request.sampler', *args)
        end
        # rubocop:enable Metrics/LineLength
      end
      it 'should save event', if: metadata[:wl] && !metadata[:bl] do
        expect(save_method).to receive(:call).with(event)
        get '/'
      end
      it 'should not save event', if: !metadata[:wl] || metadata[:bl] do
        expect(save_method).not_to receive(:call)
        get '/'
      end
    end
  end

  shared_examples 'valid probe orm' do
    let(:config) { Sampler.configuration }
    let(:save_method_name) { "save_to_#{Sampler.configuration.probe_orm}" }

    before { Sampler.configuration.probe_class = probe_class }
    it { expect { subscriber.subscribe }.not_to raise_error }

    context 'method for saving event' do
      before { save_method_name }
      it 'should be looked up once during subscription' do
        expect(config).to receive(:probe_orm).once.and_call_original.ordered
        expect(subscriber)
          .to receive(:method).with(save_method_name).once.ordered
        subscriber.subscribe
      end
    end

    context 'after subscription' do
      let(:event) { instance_double(Sampler::Event) }
      let(:save_method) { subscriber.method(save_method_name) }
      before do
        expect(subscriber).to receive(:method).with(save_method_name).once
          .and_return(save_method)
        allow(save_method).to receive(:call)
        subscriber.subscribe
      end

      before(:example) do |example|
        next if example.metadata[:args_check]
        expect(Sampler::Event).to receive(:new).once.and_return(event)
      end

      before(:example) do |ex|
        allow(event).to receive(:whitelisted?).and_return(ex.metadata[:wl])
        allow(event).to receive(:blacklisted?).and_return(ex.metadata[:bl])
      end

      [true, false].repeated_permutation(2).each do |wl, bl|
        include_examples 'call save_to', wl, bl
      end
    end
  end

  context '#event_handler', type: :request do
    # TODO: rewrite shared_examples, ugly
    subject(:subscribe) { -> { subscriber.subscribe } }
    context 'when probe_class is not set', nil_probe_class: true do
      it { should raise_error(ArgumentError) }
    end
    context 'when probe_class is NilClass' do
      let(:probe_class) { Class.new(NilClass) }
      include_examples 'valid probe orm'
    end
    context 'when probe_class is ActiveRecotd model' do
      let(:probe_class) { Class.new(ActiveRecord::Base) }
      include_examples 'valid probe orm'
    end
  end
end
