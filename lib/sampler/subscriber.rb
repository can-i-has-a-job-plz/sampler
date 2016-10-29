# frozen_string_literal: true
require 'active_support/notifications'

module Sampler
  # Subscriber that will process 'request.sampler' notifications
  class Subscriber
    def subscribe
      return true if subscribed?
      args = ['request.sampler', nil]
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
  end
end
