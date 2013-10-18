Lorious::Application.routes.draw do

  resource :requests
  
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
  end

  namespace :experts do
    resources :expertise, only: [:new, :create]
    resources :availabilities, only: [:edit, :update]
  end

  resources :experts, only: [] do
    resources :appointments
  end

  resource :users, only: [:show]
  resources :invites
  
  root :to => "home#index"
  get '/search', to: 'home#search'
  get "/search/page/:page", :controller => "home", :action => "search"

  get '/request_latest', to: 'requests#latest'
  
  match "/:username" => "users/profiles#show", via: [:get], as: :profile
end
