class LeaguesController < ApplicationController

  def index
    @leagues = League.all.includes(:teams)
  end

  def show
    @league = League.includes(:users).find_by(id: params[:id])
    redirect_to action: 'index' unless @league

    @my_team = @league.users.find(current_user.id) if signed_in?
  end

  def new
  end

  def create
  end

  def schedule
    @league = League.includes(games: [:home_team, :away_team]).find_by(id: params[:id])
    redirect_to action: 'index' unless @league

    @my_team = @league.users.find(current_user.id) if signed_in?
  end
end