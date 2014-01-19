class LeaguesController < ApplicationController
  before_action :signed_in_user, except: [:index]
  before_action :user_team, except: [:index]

  def index
    @leagues = League.all_leagues
    @user_leagues = current_user.leagues if signed_in?
  end

  def show
    @league = League.includes(:users).find_by(id: params[:league_id])
    redirect_to action: 'index' unless @league
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
  end

  def schedule
    @league = League.includes(games: [:home_team, :away_team]).find_by(id: params[:league_id])
    redirect_to(leagues_url, notice: "Selected League not found") unless @league
  end

  private

  def user_team
    @league = League.find_by(id: params[:league_id])
    @user_team = Team.find_by(user_id: current_user, league_id: @league)
  end
end