# frozen_string_literal: true
require 'rails/railtie'

module Sampler
  # @private
  class Railtie < Rails::Railtie
    config.eager_load_namespaces << Sampler

    generators do
      # :nocov:
      require 'generators/sampler'
      # :nocov:
    end
    initializer 'sampler.middleware' do |app|
      # TODO: do we want to insert our middleware into specific place?
      app.config.middleware.use Middleware
    end
  end
end
