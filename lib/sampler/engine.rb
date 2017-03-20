# frozen_string_literal: true

require 'active_support/core_ext/string/filters' # FIXME: sort out dependencies
require 'sampler/middleware'

module Sampler
  class Engine < ::Rails::Engine # :nodoc:
    isolate_namespace Sampler

    config.app_middleware.use Sampler::Middleware

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end
  end
end
