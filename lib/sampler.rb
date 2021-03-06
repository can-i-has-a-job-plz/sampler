# frozen_string_literal: true
require 'sampler/version'
require 'sampler/railtie' if defined?(Rails)

# Just a namespace for all Sampler code
module Sampler
  autoload :Configuration, 'sampler/configuration'

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end
end
