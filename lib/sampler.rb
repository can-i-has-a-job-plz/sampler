# frozen_string_literal: true
require 'sampler/version'
require 'sampler/railtie' if defined?(Rails)

# Just a namespace for all Sampler code
module Sampler
  autoload :Configuration, 'sampler/configuration'
  autoload :Middleware, 'sampler/middleware'
  autoload :Subscriber, 'sampler/subscriber'

  class << self
    attr_reader :subscriber
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  def self.start
    (@subscriber ||= Subscriber.new).subscribe
  end

  def self.stop
    subscriber&.unsubscribe
  end
end
