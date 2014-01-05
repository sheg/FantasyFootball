FantasyFootball::Application.routes.draw do
  root "fantasy_football#home"

  resources :leagues, only: [:index, :show, :new, :create] do
    get :team, on: :member
  end

  match "/join_league", to: "leagues#join", via: "get", as:"join_league"
  match "/leagues/:id/schedule", to: "leagues#schedule", via: "get", as: "league_schedule"
  match "/leagues/:league_id/team/:team_id", to: "leagues#team", via: "get", as: "league_team"


  resources :sessions, only: [:new, :create, :destroy]
  match "/signin", to: "sessions#new", via: "get"
  match "/signout", to: "sessions#destroy", via: "delete"

  resources :users, except: [:index]
  match "/users/email_exists/:email_address", to: "users#email_exists", via: "get", constraints: { :email_address => /[^\/]+/ }
  match "/users/:id/user_leagues", to: "users#user_leagues", via: "get", as: "user_leagues"
  match "/signup", to: "users#new", via: "get"
end