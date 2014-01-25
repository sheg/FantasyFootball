class TeamsController < ApplicationController
  before_action :find_team_and_league, except: [:schedule]

  def show
    @user_team = Team.includes([:user, :league]).find_by(user_id: current_user, league_id: @league)
    redirect_to(leagues_path, notice: "You are not part of this league") unless @user_team
  end

  def schedule
    if params[:team_id]
      find_team_and_league
      find_games_and_user_team
    else
      @league = League.find_by(id: params[:league_league_id])
      @team = @league.teams.first
      find_games_and_user_team
    end
    render partial: "team_schedule" if params[:use_json]
  end

  private
  def find_team_and_league
    @team = Team.find_by(id: params[:team_id])
    @league = @team.league
  end

  def find_games_and_user_team
    fail "no team set..." unless @team
    @games = Game.includes([:home_team, :away_team]).where("home_team_id = #{@team.id} OR away_team_id = #{@team.id}")
    @user_team = Team.includes([:user, :league]).find_by(user_id: current_user, league_id: @league)
  end
end