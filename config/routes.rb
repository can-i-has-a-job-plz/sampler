# frozen_string_literal: true

Sampler::Engine.routes.draw do
  resources :samples, only: %i(index show destroy) do
    delete '/all', on: :collection, to: 'samples#destroy_all'
    delete :destroy, on: :collection, to: 'samples#mass_destroy'
  end
end
