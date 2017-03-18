# frozen_string_literal: true

module Sampler
  # @private
  class Railtie < Rails::Railtie
    config.eager_load_namespaces << Sampler
    initializer 'sampler.middleware' do |app|
      # TODO: do we want to insert our middleware into specific place?
      app.config.middleware.use Middleware
    end
  end
end
