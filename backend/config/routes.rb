Rails.application.routes.draw do
  resources :accounts, only: [:index, :create, :update, :destroy]
  resources :users
  resources :subcategories, only: [:create, :update, :destroy]
  resources :categories, only: [:index, :create, :update, :destroy]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
