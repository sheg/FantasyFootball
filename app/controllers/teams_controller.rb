class TeamsController < ApplicationController

  def show
    @team = Team.find_by(id: params[:team_id])
    @league = @team.league
    @user_team = Team.includes([:user, :league]).find_by(user_id: current_user, league_id: @league)
  end

  def schedule
    @team = Team.find_by(id: params[:team_id])
    @league = @team.league
    @games = Game.includes([:home_team, :away_team]).where("home_team_id = #{@team.id} OR away_team_id = #{@team.id}")
    @user_team = Team.includes([:user, :league]).find_by(user_id: current_user, league_id: @league)

    @team_games = @games.map do |game|
      {
          week: game.week,
          home_team: game.home_team,
          away_team: game.away_team,
          home_score: game.home_score,
          away_score: game.away_score
      }
    end

    respond_to do |format|
      format.html
      format.json { render json: @team_games }
    end
  end
end
