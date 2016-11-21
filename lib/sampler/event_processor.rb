# frozen_string_literal: true
require 'concurrent/map'
require 'concurrent/timer_task'

module Sampler
  # rubocop:disable Metrics/ClassLength
  class EventProcessor # :nodoc:
    HOUR_AGO = Arel.sql("now() - interval '1 hour'").freeze
    attr_reader :events

    def initialize
      @events = Concurrent::Map.new { |m, k| m[k] = Concurrent::Array.new }
      @to_be_saved = Hash.new { |h, k| h[k] = [] }
      @events_lock = Concurrent::ReadWriteLock.new
    end

    def <<(event)
      @events_lock.with_read_lock { @events[event.endpoint] << event }
    end

    def process
      clean_empty_queues
      fill_events
      cleanup
      save_events
    end

    def start
      return true if @executor&.running?
      interval = Sampler.configuration.interval
      @executor ||= Concurrent::TimerTask.new(execution_interval: interval,
                                              timeout_interval: interval,
                                              run_now: true) do
        Sampler.configuration.event_processor.process
      end
      true
    end

    def stop
      return unless @executor&.running?
      @executor.shutdown
      @executor.wait_for_termination(5)
      @executor = nil
    end

    private

    def fill_events
      events.each_pair do |endpoint, event_queue|
        @to_be_saved[endpoint].concat(event_queue.shift(event_queue.size))
        unless max_per_endpoint.nil?
          @to_be_saved[endpoint] = @to_be_saved[endpoint].pop(max_per_endpoint)
        end
      end
    end

    def clean_empty_queues
      @events_lock.with_write_lock do
        @events.each_pair { |k, v| @events.delete(k) if v.empty? }
      end
    end

    def cleanup
      clean_max_per_endpoint unless max_per_endpoint.nil?
      clean_max_per_hour unless max_per_hour.nil?
      clean_retention_period unless retention_period.nil?
    end

    def clean_max_per_endpoint
      to_clear = probe_class.select(:endpoint)
                            .group(:endpoint)
                            .having(Arel.star.count.gt(max_per_endpoint))
                            .pluck(:endpoint)
      to_clear.each { |ep| clean_endpoint_samples(ep) }
    end

    # rubocop:disable Metrics/AbcSize
    def clean_max_per_hour
      retain_count = max_per_hour - @to_be_saved.values.map(&:size).sum
      retain = probe_class.order(created_at: :desc).limit(retain_count)
      probe_class.where(probe_class.arel_table[:created_at].gt(HOUR_AGO))
                 .where.not(id: retain.select(:id))
                 .delete_all
    end
    # rubocop:enable Metrics/AbcSize

    def clean_retention_period
      min_time = Arel.sql("now() - interval '#{retention_period} second'")
      probe_class.where(probe_class.arel_table[:created_at].lt(min_time))
                 .delete_all
    end

    def max_per_endpoint
      Sampler.configuration.max_probes_per_endpoint
    end

    def max_per_hour
      Sampler.configuration.max_probes_per_hour
    end

    def retention_period
      Sampler.configuration.retention_period
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def clean_endpoint_samples(endpoint)
      events_in_queue = if @to_be_saved.key?(endpoint)
                          @to_be_saved[endpoint].size
                        else 0
                        end
      retain_samples = probe_class.where(endpoint: endpoint)
                                  .select(:id)
                                  .order(created_at: :desc)
                                  .limit(max_per_endpoint - events_in_queue)
      probe_class.where(endpoint: endpoint)
                 .where.not(id: retain_samples)
                 .order(created_at: :desc)
                 .delete_all
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def save_events
      probe_class.transaction do
        @to_be_saved.each_value do |events|
          events.each { |e| save_event(e.to_h) }
        end
      end
      @to_be_saved.clear
    end

    def save_event(event)
      sample = probe_class.create(event)
      return if sample.save
      # TODO: what info should we add here?
      logger.warn(format('Got invalid sample: %s',
                         sample.errors.full_messages.join(', ')))
    end

    def logger
      Sampler.configuration.logger
    end

    def probe_class
      Sampler.configuration.probe_class
    end
  end
  # rubocop:enable Metrics/ClassLength
end
