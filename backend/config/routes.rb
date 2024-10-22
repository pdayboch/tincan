# frozen_string_literal: true

Rails.application.routes.draw do
  resources :transactions, only: %i[index create update destroy]
  resources :accounts, only: %i[index create update destroy] do
    collection do
      get :supported, to: 'supported_accounts#index'
    end
  end
  resources :users, only: %i[index create update destroy]
  resources :subcategories, only: %i[create update destroy]
  resources :categories, only: %i[index create update destroy]

  namespace :categorization do
    resources :conditions, only: %i[index create update destroy]
    resources :rules, only: %i[index create update destroy]
  end

  resources :trends, only: [] do
    collection do
      get 'overTime', to: 'trends#over_time'
    end
  end
end
