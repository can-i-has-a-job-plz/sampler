# frozen_string_literal: true
require 'sampler/version'
require 'sampler/railtie' if defined?(Rails)

# Just a namespace for all Sampler code
module Sampler
  autoload :Configuration, 'sampler/configuration'
  autoload :Middleware, 'sampler/middleware'

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end
end
