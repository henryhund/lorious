require 'sidekiq/web'
Lorious::Application.routes.draw do

  resources :requests
  
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks",
                                        :registrations => "users/registrations" }

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
    resources :appointments do
      member do
        post "confirm"
      end
    end
  end

  resource :users, only: [:show]
  resources :invites
  resources :credit_transaction, :controller => "credits"
  
  root :to => "home#index"
  get '/search', to: 'home#search'
  get "/search/page/:page", :controller => "home", :action => "search"
  get '/subscriptions', to: 'home#subscriptions'
  get '/request_latest', to: 'requests#latest'
  
  post '/add_credit', :controller => "credits", :action => "add_credit"
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
  
  match "/:username" => "users/profiles#show", via: [:get], as: :profile
  
  match 'payments/new' => 'payments#new', via: [:get], :as => :new_payment
  match 'payments/confirm' => 'payments#confirm', via: [:get], :as => :confirm_payment

  
end
