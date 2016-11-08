# frozen_string_literal: true
require 'active_support/notifications'

module Sampler
  # Subscriber that will process 'request.sampler' notifications
  class Subscriber
    def subscribe
      return true if subscribed?
      args = ['request.sampler', event_handler]
      @subscription = Sampler::Notifications.subscribe(*args)
      true # Don't leak subscription here
    end

    def unsubscribe
      Sampler::Notifications.unsubscribe(@subscription)
    end

    def subscribed?
      Sampler::Notifications.notifier
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

    # rubocop:disable Metrics/AbcSize
    def save_to_active_record(event)
      delete_from_ar_max_per_hour
      delete_from_ar_max_per_endpoint(event.endpoint)
      delete_from_ar_old_probes
      Sampler.configuration.probe_class.create!(
        endpoint: event.endpoint, url: event.url, method: event.method,
        params: event.params, request_body: event.request_body,
        response_body: event.response_body, tags: event.tags,
        created_at: event.time, updated_at: event.end
      )
    end

    def delete_from_ar_max_per_hour
      return if config.max_probes_per_hour.nil?
      retain = klass.order(created_at: :desc)
                    .limit(config.max_probes_per_hour - 1)
                    .select(:id)
      last_hour = klass.order(created_at: :desc)
                       .where(klass.arel_table[:created_at]
                                   .gt(Arel.sql("now() - interval '1 hour'")))
      last_hour.where.not(id: retain).delete_all
    end

    def delete_from_ar_max_per_endpoint(endpoint)
      return if config.max_probes_per_endpoint.nil?
      retain = klass.where(endpoint: endpoint)
                    .order(created_at: :desc)
                    .limit(config.max_probes_per_endpoint - 1)
                    .select(:id)
      our_endpoint = klass.order(created_at: :desc)
                          .where(endpoint: endpoint)
      our_endpoint.where.not(id: retain).delete_all
    end
    # rubocop:enable Metrics/AbcSize

    def delete_from_ar_old_probes
      return if config.retention_period.nil?
      min_time = "now() - interval '#{config.retention_period} second'"
      klass.where(klass.arel_table[:created_at].lt(Arel.sql(min_time)))
           .delete_all
    end

    def config
      Sampler.configuration
    end

    def klass
      config.probe_class
    end
  end
end
