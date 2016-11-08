require 'sampler/notifications/instrumenter'
require 'sampler/notifications/fanout'
require 'active_support/per_thread_registry'

module Sampler
  module Notifications
    autoload :Instrumenter, 'sampler/notifications/instrumenter'
    autoload :Fanout, 'sampler/notifications/fanout'

    class << self
      attr_accessor :notifier

      def publish(name, *args)
        notifier.publish(name, *args)
      end

      def instrument(name, payload = {})
        if notifier.listening?(name)
          instrumenter.instrument(name, payload) { yield payload if block_given? }
        else
          yield payload if block_given?
        end
      end

      def subscribe(*args, &block)
        notifier.subscribe(*args, &block)
      end

      def subscribed(callback, *args, &block)
        subscriber = subscribe(*args, &callback)
        yield
      ensure
        unsubscribe(subscriber)
      end

      def unsubscribe(subscriber_or_name)
        notifier.unsubscribe(subscriber_or_name)
      end

      def instrumenter
        InstrumentationRegistry.instance.instrumenter_for(notifier)
      end
    end

    # This class is a registry which holds all of the +Instrumenter+ objects
    # in a particular thread local. To access the +Instrumenter+ object for a
    # particular +notifier+, you can call the following method:
    #
    #   InstrumentationRegistry.instrumenter_for(notifier)
    #
    # The instrumenters for multiple notifiers are held in a single instance of
    # this class.
    class InstrumentationRegistry # :nodoc:
      extend ActiveSupport::PerThreadRegistry

      def initialize
        @registry = {}
      end

      def instrumenter_for(notifier)
        @registry[notifier] ||= Instrumenter.new(notifier)
      end
    end

    self.notifier = Fanout.new
  end
end
