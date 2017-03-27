# frozen_string_literal: true

module Sampler
  class Configuration # :nodoc:
    def initialize
      @running = false
    end

    def start
      @running = true
    end

    def stop
      @running = false
    end

    def running?
      @running
    end
  end
end
