FantasyFootball::Application.routes.draw do

  root "fantasy_football#home"

  resources :leagues, param: :league_id, only: [:index, :show, :new, :create] do
    member do
      get :schedule
      get :standings
      get :league_info
      get :draft
    end
    resources :teams, param: :team_id, only: [:show, :destroy] do
      get :schedule, on: :collection
      get :set_lineup, on: :member
    end
  end

  match "/join_league", to: "leagues#join", via: "get", as:"join_league"

  resources :sessions, only: [:new, :create, :destroy], path_names: { new: 'signin', destroy: 'signout' }
  match "/signin", to: "sessions#new", via: "get"
  match "/signout", to: "sessions#destroy", via: "delete"

  resources :users, except: [:index]
  match "/users/email_exists/:email_address", to: "users#email_exists", via: "get", constraints: { :email_address => /[^\/]+/ }
  match "/signup", to: "users#new", via: "get"
end