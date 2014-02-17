class LeaguesController < ApplicationController
  before_action :signed_in_user, except: [:index]
  before_action :user_team, except: [:index, :new, :create, :join]
  before_action :get_current_week, except: [:index, :join]

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
    league = League.find(params[:league_id])

    if current_user.leagues.include?(league)
      redirect_to(league, notice: "You are already part of this league")
      return
    end

    if league.full?
      redirect_to(leagues_url, notice: "League Full - Please join an available league")
      return
    end

    team_name = "#{Faker::Name.title}--#{Random.rand(1000000)}"
    Team.create!(name: team_name, user_id: current_user.id, league_id: league.id)

    redirect_to(league_path(league), notice: "Welcome to #{league.name}!")
  end

  def standings
    @league = League.includes(games: [:home_team, :away_team]).find_by(id: params[:league_id])
  end

  def schedule
    @league = League.includes(games: [:home_team, :away_team]).find_by(id: params[:league_id])

    unless @league
      redirect_to(leagues_path, notice: "Selected League not found")
      return
    end

    unless @league.games
      redirect_to(league_path(@league), notice: "No games have been defined yet")
      return
    end
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

  def get_current_week
    render text: "Current league is not set..." unless @league

    if @league.started?
      current_week_data = @league.get_league_week_data_for_week
      if current_week_data
        @current_week = current_week_data.week_number
      else
        @current_week = @league.weeks
      end
    else
      @current_week = 0 #You should see your league before it starts - counting down or something...
    end
  end
end