# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rails' # Needed for Railtie
require 'sampler'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before do
    Sampler.stop
    ActiveSupport::Notifications.unsubscribe('request.sampler')
    Sampler.instance_variable_set(:@subscriber, nil)
    Sampler.instance_variable_set(:@configuration, nil)
  end
end
