# frozen_string_literal: true

Rails.application.routes.draw do
  resources :transactions, only: %i[index create update destroy]
  resources :accounts, only: %i[index create update destroy]
  resources :users, only: %i[index create update destroy]
  resources :subcategories, only: %i[create update destroy]
  resources :categories, only: %i[index create update destroy]

  namespace :categorization do
    resources :conditions, only: %i[index create update destroy]
    resources :rules, only: %i[index create update destroy]
  end

  get 'accounts/supported', to: 'supported_accounts#index'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
