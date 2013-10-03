Lorious::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root :to => "home#index"
  get '/search', to: 'home#search'
  get "/search/page/:page", :controller => "home", :action => "search"
end
