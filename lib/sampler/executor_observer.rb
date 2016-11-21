# frozen_string_literal: true
module Sampler # :nodoc:
  class ExecutorObserver # :nodoc:
    def update(_time, result, ex)
      if result
        logger.debug('Sampler successfully processed events')
      elsif ex.is_a?(Concurrent::TimeoutError)
        logger.warn('Sampler timed out while saving events')
      else
        logger.warn("Sampler got #{ex.class} (#{ex}) while saving events")
      end
    end

    private

    def logger
      Sampler.configuration.logger
    end
  end
end
