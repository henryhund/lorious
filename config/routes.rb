Lorious::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks",
                                        :registrations => "users/registrations" }

  namespace :users do
    resources :social_media
    resources :steps, only: [:edit, :update]
  end

  match "profile" => "users#show", as: :profile, via: [:get]
  resource :users, only: [:show]
  resources :invites
  
  root :to => "home#index"
  get '/search', to: 'home#search'
  get "/search/page/:page", :controller => "home", :action => "search"
end
