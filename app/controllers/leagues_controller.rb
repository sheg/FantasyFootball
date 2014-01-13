class LeaguesController < ApplicationController
  before_action :signed_in_user, except: [:index]

  def index
    @leagues = League.all_leagues
    @user_leagues = current_user.leagues if signed_in?
  end

  def show
    @league = League.includes(:users).find_by(id: params[:league_id])
    redirect_to action: 'index' unless @league
    @user_team = Team.find_by(user_id: current_user, league_id: @league)
  end

  def new
  end

  def create
  end

  def join
    redirect_to action: 'index' #for now...
  end

  def standings
    @league = League.find_by(id: params[:league_id])
    redirect_to action: 'index' unless @league
    @user_team = Team.find_by(user_id: current_user, league_id: @league)
  end
end