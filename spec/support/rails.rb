# frozen_string_literal: true

module Sampler
  class Application < Rails::Application # :nodoc:
    config.eager_load = false # Just to silence a warning
  end
end

Rails.initialize!

Rails.application.routes.draw do
  mount Rails.application => '/loop', internal: true

  resources :authors

  get '/books/:id', id: /\d+/, to: 'controller#action'
  get '/books/*whatever', to: 'controller#action'
end
