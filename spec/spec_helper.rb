# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry-byebug'
require 'rails'
require 'sampler'
require 'shoulda-matchers'
require 'factory_girl'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.alias_it_should_behave_like_to :include_context

  config.before(:suite) do
    FactoryGirl.find_definitions
    FactoryGirl.lint
  end
  config.after { Sampler.instance_variable_set(:@configuration, nil) }
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
  end
end
