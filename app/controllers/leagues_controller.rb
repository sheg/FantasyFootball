class LeaguesController < ApplicationController
  before_action :signed_in_user, except: [:index]
  before_action :user_team, except: [:index, :new, :create, :join]
  before_action :set_current_week, except: [:index] #SANDBOX PURPOSES FOR NOW!

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
    @league = League.includes(games: [:home_team, :away_team]).find_by(id: params[:league_id])
  end

  def schedule
    @league = League.includes(games: [:home_team, :away_team]).find_by(id: params[:league_id])
    redirect_to(leagues_path, notice: "Selected League not found") unless @league
  end

  def league_info
  end

  private

  def user_team
    @league = League.find_by(id: params[:league_id])
    unless @league
      redirect_to(leagues_path, notice: "Selected League not found")
      return
    end

    @user_team = Team.find_by(user_id: current_user, league_id: @league)
    redirect_to(leagues_path, notice: "You are not part of the this league") unless @user_team
  end

  #sandbox purposes... for now
  def set_current_week
    render text: "Current league is not set" unless @league
    @current_week = @league.get_league_week_data(2.weeks.from_now).week_number + 1
  end
end