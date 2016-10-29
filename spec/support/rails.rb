# frozen_string_literal: true
# TODO: we should require AR when needed, not now
require 'active_record'

module Sampler
  class Application < Rails::Application # :nodoc:
    config.eager_load = false # Just to silence a warning
  end
end

Rails.initialize!