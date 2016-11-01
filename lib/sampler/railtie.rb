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
  end
end
