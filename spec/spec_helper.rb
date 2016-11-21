# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rails' # Needed for Railtie
require 'sampler'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before { Sampler.instance_variable_set(:@configuration, nil) }
  config.after { Sampler.stop }
end
