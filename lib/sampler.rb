# frozen_string_literal: true
require 'sampler/version'
require 'sampler/railtie' if defined?(Rails)

# Just a namespace for all Sampler code
module Sampler
  autoload :Configuration, 'sampler/configuration'
  autoload :Middleware, 'sampler/middleware'
  autoload :Event, 'sampler/event'
  autoload :EventProcessor, 'sampler/event_processor'
  autoload :ExecutorObserver, 'sampler/executor_observer'

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  def self.start
    configuration.start
  end

  def self.stop
    configuration.stop
  end

  def self.running?
    configuration.running
  end
end
