FantasyFootball::Application.routes.draw do
  root "fantasy_football#home"
  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:show, :new, :create, :edit, :update, :destroy]
  match "/signup", to: "users#new", via: "get"
  match "/signin", to: "sessions#new", via: "get"
  match "/signout", to: "sessions#destroy", via: "delete"
  match "/users/email_exists/:email_address", to: "users#email_exists", via: "get", constraints: { :email_address => /[^\/]+/ }

  resources :leagues
end
