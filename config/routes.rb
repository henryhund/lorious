Lorious::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  match "account" => "users#show", as: :account, via: [:get]
  resource :users, only: [:show]
  
  root :to => "home#index"
  
end
