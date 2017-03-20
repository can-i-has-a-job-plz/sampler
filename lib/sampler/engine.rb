# frozen_string_literal: true

require 'active_support/core_ext/string/filters' # FIXME: sort out dependencies

module Sampler
  class Engine < ::Rails::Engine # :nodoc:
    isolate_namespace Sampler

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
