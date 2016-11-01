# frozen_string_literal: true
module Sampler
  class Application < Rails::Application # :nodoc:
    config.eager_load = false # Just to silence a warning
  end
end

Rails.initialize!
