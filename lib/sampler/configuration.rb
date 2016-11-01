# frozen_string_literal: true
module Sampler
  # Stores runtime Sampler configuration information.
  # @example Standard settings
  #     Sampler.configure do |config|
  #       config.probe_class = Sample
  #     end
  class Configuration
    attr_accessor :probe_class
  end
end
