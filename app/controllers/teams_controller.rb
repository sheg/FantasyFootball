class TeamsController < ApplicationController
  include TeamHelper

  before_action :find_team_and_league, except: [:schedule]

  def show
    @user_team = Team.includes([:user, :league]).find_by(user_id: current_user, league_id: @league)
    redirect_to(leagues_path, notice: "You are not part of this league") unless @user_team

    if @league.started?
      @roster_data = @user_team.get_league_week_stats(1)
    else
      redirect_to(@league, notice: "No team yet - Please execute a draft first")
    end
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

  def destroy
    team = Team.find_by(id: params[:team_id])
    if team
      league = team.league
      leave_league(league, team)
    else
      redirect_to(leagues_path, notice: "No Team Selected...")
    end
  end

  private

    def find_team_and_league
      @team = Team.includes([:league, :user]).find_by(id: params[:team_id])
      @league = @team.league
    end

    def find_games_and_user_team
      render text: "No Team Found..." unless @team
      @games = Game.includes([:home_team, :away_team]).where("home_team_id = #{@team.id} OR away_team_id = #{@team.id}")
      @user_team = Team.includes([:user, :league]).find_by(user_id: current_user, league_id: @league)
    end
end