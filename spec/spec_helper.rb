# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sampler'

RSpec.configure do |config|
  config.before { Sampler.instance_variable_set(:@configuration, nil) }
end
