# frozen_string_literal: true

module Sampler # :nodoc:
  class ExecutorObserver # :nodoc:
    def update(_time, result, ex)
      if result
        Sampler.logger.debug("Sampler successfully processed #{result} events")
      elsif ex.is_a?(Concurrent::TimeoutError)
        Sampler.logger.warn('Sampler timed out while saving events')
      else
        Sampler.logger.warn("Sampler got #{ex.class} (#{ex}) " \
                            'while saving events')
      end
    end
  end
end
