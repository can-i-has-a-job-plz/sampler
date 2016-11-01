# frozen_string_literal: true
module Sampler
  class Application < Rails::Application # :nodoc:
    config.root = File.expand_path('../../rails_root', __FILE__)
    config.eager_load = false # Just to silence a warning
  end
end

Rails.initialize!
