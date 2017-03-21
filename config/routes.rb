# frozen_string_literal: true

Sampler::Engine.routes.draw do
  resources :samples, only: [:index]
end
