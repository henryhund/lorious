require 'sidekiq/web'
Lorious::Application.routes.draw do
  
  authenticated :user do
    root to: "home#dashboard", as: :authenticated_root
  end
  
  unauthenticated do
    root to: "home#index", as: :root
  end

  resources :requests
  
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks",
                                        :registrations => "users/registrations",
                                        :sessions => "users/sessions" }

  namespace :users do
    resources :social_media
    resources :steps, only: [:edit, :update]
    resource :profile, only: [:show]
    resources :interests, only: [:new, :create]
    resources :appointments, only: [:index] do
      collection do
        get "pending"
        get "upcoming"
        get "history"
      end
    end
    resources :credit_transaction, only: [:index], :controller => 'credits' do
      collection do
        get "transactions"
      end
    end
    resources :requests_made, only: [:index], :controller => 'requests' do
      collection do
        get "new_request"
        get "withdrawn"
        get "completed"
      end
    end
  end

  namespace :experts do
    resources :expertise, only: [:new, :create]
    resources :availabilities, only: [:edit, :update]
  end

  resources :experts, only: [] do
    resources :reviews
    resources :appointments do
      member do
        post "confirm"
        post "cancel"
        post "new_conversation" 
      end
    end
  end

  resource :users, only: [:show]
  resources :invites
  resources :credit_transaction, :controller => "credits"
  
  get '/search', to: 'home#search'
  get "/search/page/:page", :controller => "home", :action => "search"
  get '/subscriptions', to: 'home#subscriptions'
  get '/request_latest', to: 'requests#latest'
  
  post '/new_conversation', :controller => "conversations", :action => "create"
  
  
  post '/new_review', :controller => "home", :action => "new_review"
  post '/search', to: 'home#search'
  
  resources :conversations do
    member do
      delete 'trash'
      post 'untrash'
    end
    collection do
      delete 'trash'
    end
  end
  
  mount Sidekiq::Web, at: "/sidekiq"
  
  post '/messages', :controller => "conversations", :action => "create_message"
  
  match 'hangout/request' => 'appointments#new_hangout', via: [:get]
  
  match '/webhooks' => 'payments#webhooks', via: [:get]
  match '/webhooks' => 'payments#webhook_process', via: [:post]
  
  match 'payments/new' => 'payments#new', via: [:get], :as => :new_payment
  
  match 'payments/credit_card' => 'payments#credit_card', via: [:get], :as => :credit_card
  match 'payments/new_credit_card' => 'payments#new_credit_card', via: [:get], :as => :new_credit_card
  
  match 'payments/merchant' => 'payments#merchant', via: [:get], :as => :merchant
  match 'payments/new_merchant' => 'payments#new_merchant', via: [:post], :as => :new_merchant
  
  match 'payments/confirm' => 'payments#confirm', via: [:get], :as => :confirm_payment
  
  match 'payments/temp' => 'payments#temp', via: [:get]
  
  match "/control_panel" => "home#control_panel", via: [:get], as: :control_panel
  
  match "update_multiple_experts" => "home#update_experts", via: [:put], as: :update_multiple_experts
  match "update_multiple_settings" => "home#update_settings", via: [:put], as: :update_multiple_settings
  match "update_multiple_transactions" => "home#update_transactions", via: [:put], as: :update_multiple_transactions
  
  match "/:username" => "users/profiles#show", via: [:get], as: :profile
  
end
