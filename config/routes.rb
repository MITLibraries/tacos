Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }, only: [:omniauth_callbacks]
  devise_scope :user do
    delete '/users/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  namespace :admin do
    # Lookup-style detector records
    namespace :detector do
      resources :suggested_resources
    end

    # Knowledge graph models
    resources :detectors
    resources :detector_categories
    resources :categories
    resources :categorizations, only: [:index, :show]

    # Search activity models
    resources :search_events, only: [:index, :show]
    resources :terms, only: [:index, :show, :destroy]

    # Tacos administration
    resources :users

    root to: "terms#index"
  end

  post '/graphql', to: 'graphql#execute'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'playground', to: 'static#playground'
  get '/report', to: 'report#index'
  get '/report/algorithm_metrics', to: 'report#algorithm_metrics'

  # Defines the root path route ("/")
  root to: 'static#index'
end
