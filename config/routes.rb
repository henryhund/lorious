require 'sidekiq/web'
Lorious::Application.routes.draw do
  root :to => "home#index"
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
  match 'payments/new' => 'payments#new', via: [:get], :as => :new_payment
  match 'payments/confirm' => 'payments#confirm', via: [:get], :as => :confirm_payment
  match 'payments/repeat' => 'payments#repeat', via: [:get], :as => :repeat_payment
  match 'payments/new_merchant' => 'payments#new_merchant', via: [:post], :as => :new_merchant
  
  match "/:username" => "users/profiles#show", via: [:get], as: :profile
  
  namespace :payments do
    post "type1"
    post "type2"
    post "type3"
  end
  
  
  
  
  
end
