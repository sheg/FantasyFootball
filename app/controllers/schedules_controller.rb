class SchedulesController < ApplicationController

  def show
    @team = Team.find_by(id: params[:team_id])
    @league = @team.league
    @games = Game.includes([:home_team, :away_team]).where("home_team_id = #{@team.id} OR away_team_id = #{@team.id}")
    @user_team = Team.includes([:user, :league]).find_by(user_id: current_user, league_id: @league)

    respond_to do |format|
      format.html
      format.json { render json: @league }
    end
  end
end