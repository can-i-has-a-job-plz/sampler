# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rails.application => '/loop', internal: true

  resources :authors

  get '/books/:id', id: /\d+/, to: 'controller#action'
  get '/books/*whatever', to: 'controller#action'
end
