Lorious::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks",
                                        :registrations => "users/registrations" }

  namespace :users do
    resources :social_media
  end

  match "profile" => "users#show", as: :profile, via: [:get]
  resource :users, only: [:show]
  
  root :to => "home#index"
  
end
