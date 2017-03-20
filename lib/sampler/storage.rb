# frozen_string_literal: true

module Sampler
  class Storage # :nodoc:
    def initialize
      @events = Concurrent::Map.new { |m, k| m[k] = Concurrent::Array.new }
    end

    def <<(event)
      if event.is_a?(Event) && event.endpoint
        @events[event.endpoint] << event
      elsif event.is_a?(Event)
        Sampler.logger.warn("Got event with nil endpoint #{event}")
      else
        Sampler.logger.warn("Got #{event} instead of Event")
      end
    end

    def events
      to_be_saved = []
      @events.each_key { |k| to_be_saved.concat(@events.delete(k)) }
      to_be_saved
    end
  end
end
