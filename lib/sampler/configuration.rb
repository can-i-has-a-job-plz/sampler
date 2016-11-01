# frozen_string_literal: true
module Sampler
  # Stores runtime Sampler configuration information.
  # @example Standard settings
  #     Sampler.configure do |config|
  #       config.probe_class = Sample
  #     end
  class Configuration
    # TODO: should we initialize it to some default value?
    # TODO: check if it's really a Class (not Module etc)?
    attr_accessor :probe_class
  end
end
