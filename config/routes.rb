FantasyFootball::Application.routes.draw do
  root "fantasy_football#home"

  resources :leagues, only: [:index, :show, :new, :create]

  resources :sessions, only: [:new, :create, :destroy]
  match "/signin", to: "sessions#new", via: "get"
  match "/signout", to: "sessions#destroy", via: "delete"

  resources :users, except: [:index]
  match "/users/email_exists/:email_address", to: "users#email_exists", via: "get", constraints: { :email_address => /[^\/]+/ }
  match "/users/:id/user_leagues", to: "users#user_leagues", via: "get", as: "user_leagues"
  match "/signup", to: "users#new", via: "get"
end