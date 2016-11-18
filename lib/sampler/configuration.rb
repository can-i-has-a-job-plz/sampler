# frozen_string_literal: true
require 'logger'

module Sampler
  # Stores runtime Sampler configuration information.
  # @example Standard settings
  #     Sampler.configure do |config|
  #       config.probe_class = Sample
  #     end
  class Configuration
    attr_reader :probe_class, :probe_orm, :running
    attr_accessor :logger, :event_processor

    def initialize
      @logger = Logger.new(nil)
      @event_processor = EventProcessor.new
      @running = false
    end

    def probe_class=(klass)
      # TODO: should we initialize it to some default value?
      # TODO: check if it's really a Class (not Module etc)?
      @probe_orm = orm_for_class(klass)
      @probe_class = klass
    end

    def start
      @running = true
    end

    def stop
      @running = false
    end

    private

    def orm_for_class(klass)
      if defined?(ActiveRecord::Base) && klass < ActiveRecord::Base
        return :active_record
      end
      # TODO: suggest to file an issue
      raise ArgumentError, 'Unsupported ORM'
    end
  end
end
