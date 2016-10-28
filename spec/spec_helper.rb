# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rails'
require 'sampler'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
