# frozen_string_literal: true

require 'forwardable'

module Sampler
  class Processor # :nodoc:
    extend Forwardable

    def process
      Sample.connection_pool.with_connection do
        saved = save_events
        clean_max_per_endpoint(max_per_endpoint)
        saved
      end
    end

    private

    def configuration
      Sampler.configuration
    end

    def_delegators :configuration, :events, :max_per_endpoint

    def save_events
      events.count { |event| save(event) }
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
  end
end
