class LeaguesController < ApplicationController
  before_action :signed_in_user, except: [:index]

  def index
    @leagues = League.all.includes(:teams)
    @user_leagues = current_user.leagues if signed_in?
  end

  def show
    @league = League.includes(:users).find_by(id: params[:id])
    redirect_to action: 'index' unless @league

    @user_team = Team.find_by(user_id: current_user.id, league_id: @league.id)
  end

  def new
  end

  def create
  end

  def schedule
    @league = League.includes(games: [:home_team, :away_team]).find_by(id: params[:id])
    redirect_to action: 'index' unless @league

    @user_team = Team.find_by(user_id: current_user.id, league_id: @league.id)
  end

  def join
    redirect_to action: 'index' #for now...
  end

  def team
    @league = League.includes(:users).find_by(id: params[:league_id])
    @my_team = @league.users.find(current_user.id).inspect
  end
end

private

  def signed_in_user
    redirect_to signin_url, notice: "Please sign in" unless signed_in?
  end