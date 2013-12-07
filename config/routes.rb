FantasyFootball::Application.routes.draw do
  root "fantasy_football#home"
  resources :users, only: [:show, :new, :create, :update, :destroy]
  resources :sessions, only: [:new, :create, :destroy]
  match "/signup", to: "users#new", via: "get"
  match "/signin", to: "sessions#new", via: "get"
  match "/signout", to: "sessions#destroy", via: "delete"
end
