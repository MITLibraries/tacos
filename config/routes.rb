Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }, only: [:omniauth_callbacks]
  devise_scope :user do
    delete '/users/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  namespace :admin do
    namespace :detector do
      resources :suggested_resources
    end

    resources :search_events
    resources :terms

    resources :users

    root to: "terms#index"
  end

  post '/graphql', to: 'graphql#execute'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root to: 'static#index'
end
