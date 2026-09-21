Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }, only: [:omniauth_callbacks]
  devise_scope :user do
    delete '/users/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  namespace :admin do
    # Knowledge graph models
    resources :detectors
    resources :detector_categories
    resources :categories
    resources :categorizations, only: [:index, :show]
    resources :suggested_patterns
    resources :suggested_resources

    # Search activity models
    resources :search_events, only: [:index, :show]
    resources :terms, only: [:index, :show, :destroy]

    # Tacos administration
    resources :users

    root to: "terms#index"
  end

  post '/graphql', to: 'graphql#execute'

  get 'playground', to: 'static#playground'
  get '/report', to: 'report#index'
  get '/report/algorithm_metrics', to: 'report#algorithm_metrics'

  # Suggestion management interface
  get '/suggestions', to: 'suggestion#index'
  get '/suggestions/resources', to: 'suggested_resource#index', as: 'suggested_resource'
  get '/suggestions/resources/new', to: 'suggested_resource#new', as: 'suggested_resource_new'
  post '/suggestions/resources', to: 'suggested_resource#create', as: 'suggested_resource_create'
  get '/suggestions/resources/:id', to: 'suggested_resource#edit', as: 'suggested_resource_edit'
  patch '/suggestions/resources/:id', to: 'suggested_resource#update', as: 'suggested_resource_update'
  get '/suggestions/patterns', to: 'suggested_pattern#index', as: 'suggested_pattern'

  # Confirmation interface
  get '/terms/unconfirmed', to: 'term#unconfirmed', as: 'terms_unconfirmed'
  resources :terms do
    resources :confirmation, only: [:new, :create]
  end

  # Demo interface
  get '/demo', to: 'demo#index'
  post '/demo', to: 'demo#view'

  # Interventions
  get '/intervention/doi', to: 'intervention#doi'

  # Defines the root path route ("/")
  root to: 'static#index'
end
