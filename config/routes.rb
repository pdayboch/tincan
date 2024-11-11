# frozen_string_literal: true

Rails.application.routes.draw do
  resources :transactions, only: %i[index create update destroy] do
    member do
      get :splits, to: 'transactions/splits#show'
      patch 'sync-splits', to: 'transactions/splits#sync'
    end
  end

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

  post 'categorization-jobs',
       to: 'categorization_jobs#create'
  get 'categorization-jobs/:id/status',
      to: 'categorization_jobs#status',
      as: :status_categorization_job

  resources :trends, only: [] do
    collection do
      get 'overTime', to: 'trends#over_time'
    end
  end
end
