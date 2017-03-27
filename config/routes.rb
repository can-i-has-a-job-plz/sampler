# frozen_string_literal: true

Sampler::Engine.routes.draw do
  resources :samples, only: %i(index show) do
    delete '/all', on: :collection, to: 'samples#destroy_all'
  end
end
