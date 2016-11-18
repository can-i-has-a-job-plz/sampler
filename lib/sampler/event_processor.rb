# frozen_string_literal: true
require 'concurrent/map'

module Sampler
  class EventProcessor # :nodoc:
    attr_reader :events

    def initialize
      @events = Concurrent::Map.new { |m, k| m[k] = Concurrent::Array.new }
      @to_be_saved = Hash.new { |h, k| h[k] = [] }
    end

    def process
      fill_events
      save_events
    end

    private

    def fill_events
      events.each_pair do |endpoint, event_queue|
        @to_be_saved[endpoint].concat(event_queue.shift(event_queue.size))
      end
    end

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
end
