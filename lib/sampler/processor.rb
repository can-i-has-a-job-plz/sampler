# frozen_string_literal: true

require 'forwardable'

module Sampler
  class Processor # :nodoc:
    extend Forwardable

    def process
      Sample.connection_pool.with_connection do
        saved = save_events(max_per_interval)
        clean_max_per_endpoint(max_per_endpoint)
        clean_retention_period(retention_period)
        saved
      end
    end

    private

    def configuration
      Sampler.configuration
    end

    def_delegators :configuration, :events, :max_per_endpoint,
                   :max_per_interval, :retention_period

    def save_events(max_count)
      saved_count = 0
      events.each do |event|
        saved_count += 1 if save(event)
        break if max_count && saved_count >= max_count
      end
      saved_count
    end

    def save(event)
      sample = Sample.new(event.to_h)
      return true if sample.save
      Sampler.logger.warn("Got invalid sample from #{event}, " \
                          "errors: #{sample.errors.full_messages}")
      false
    end

    def clean_max_per_endpoint(retain_count)
      return if retain_count.nil?
      endpoints = Sample.select(:endpoint, :request_method)
                        .group(:endpoint, :request_method)
                        .having('COUNT(*) > ?', retain_count)
                        .map { |e| e.attributes.except('id') }
      endpoints.each do |endpoint|
        Sample.where(endpoint)
              .where.not(id: retained_samples(endpoint, retain_count))
              .delete_all
      end
    end

    def retained_samples(endpoint, count)
      Sample.where(endpoint)
            .order(created_at: :desc)
            .limit(count)
            .select(:id)
    end

    def clean_retention_period(period)
      return if period.nil?
      Sample.where('created_at < ?', period.seconds.ago)
            .delete_all
    end
  end
end
