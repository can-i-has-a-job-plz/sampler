# frozen_string_literal: true
require 'active_support/notifications'

module Sampler
  # Subscriber that will process 'request.sampler' notifications
  class Subscriber
    def subscribe
      return true if subscribed?
      args = ['request.sampler', event_handler]
      @subscription = ActiveSupport::Notifications.subscribe(*args)
      true # Don't leak subscription here
    end

    def unsubscribe
      ActiveSupport::Notifications.unsubscribe(@subscription)
    end

    def subscribed?
      ActiveSupport::Notifications.notifier
                                  .listeners_for('request.sampler')
                                  .include?(@subscription)
    end

    private

    def event_handler
      # TODO: more meaningful error here
      raise ArgumentError if Sampler.configuration.probe_class.nil?
      save_method = method("save_to_#{Sampler.configuration.probe_orm}")
      lambda do |*args|
        event = Event.new(*args)
        return unless event.whitelisted?
        return if event.blacklisted?
        save_method.call(event)
      end
    end

    def save_to_nil_record(_event)
    end

    def save_to_active_record(_event)
    end
  end
end
