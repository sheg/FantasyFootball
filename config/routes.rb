FantasyFootball::Application.routes.draw do

  root "fantasy_football#home"

  resources :leagues, param: :league_id, only: [:index, :show, :new, :create] do
    member do
      get :schedule
      get :standings
      get :league_info
    end
    resources :teams, param: :team_id, only: [:show] do
      get :schedule, on: :collection
    end
  end

  match "/join_league", to: "leagues#join", via: "get", as:"join_league"
  match "/leave_league", to: "leagues#leave", via: "post", as:"leave_league"

  resources :sessions, only: [:new, :create, :destroy], path_names: { new: 'signin', destroy: 'signout' }
  match "/signin", to: "sessions#new", via: "get"
  match "/signout", to: "sessions#destroy", via: "delete"

  resources :users, except: [:index]
  match "/users/email_exists/:email_address", to: "users#email_exists", via: "get", constraints: { :email_address => /[^\/]+/ }
  match "/users/:id/user_leagues", to: "users#user_leagues", via: "get", as: "user_leagues"
  match "/signup", to: "users#new", via: "get"
end