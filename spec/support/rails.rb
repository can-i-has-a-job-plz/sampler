# frozen_string_literal: true
# TODO: we should require AR when needed, not now
require 'active_record'

module Sampler
  class Application < Rails::Application # :nodoc:
    config.eager_load = false # Just to silence a warning
    config.root = File.expand_path('../rails_root', __FILE__)
  end
end

Rails.initialize!

Rails.application.routes.draw do
  resources :authors
  # Just to have multiple route matches
  put '/authors/*whatever', to: 'controller#action'
end
