# frozen_string_literal: true

require 'forwardable'
require 'sampler/version'
require 'sampler/engine'

# Just a namespace for all Sampler code
module Sampler
  autoload :Middleware, 'sampler/middleware'
  autoload :Event, 'sampler/event'
  autoload :Configuration, 'sampler/configuration'
  autoload :Storage, 'sampler/storage'
  autoload :Processor, 'sampler/processor'
  autoload :ExecutorObserver, 'sampler/executor_observer'

  extend SingleForwardable

  def_delegators :configuration, :start, :stop, :running?, :sampled?, :logger

  module_function

  def configuration
    @configuration ||= Configuration.new
  end

  def configure
    yield configuration
  end
end
