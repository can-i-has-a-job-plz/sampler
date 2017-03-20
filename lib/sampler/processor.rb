# frozen_string_literal: true

require 'forwardable'

module Sampler
  class Processor # :nodoc:
    extend Forwardable

    def process
      Sample.connection_pool.with_connection do
        save_events
      end
    end

    private

    def configuration
      Sampler.configuration
    end

    def_delegators :configuration, :events

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
  end
end
