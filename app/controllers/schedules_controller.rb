class SchedulesController < ApplicationController

  def index
    @league = League.includes(games: [:home_team, :away_team]).find_by(id: params[:league_id])
    redirect_to leagues_url unless @league

    @user_team = Team.find_by(user_id: current_user, league_id: @league)
  end

  def show
    @team = Team.find_by(id: params[:team_id])
    @league = @team.league
    @games = Game.where("home_team_id = #{params[:team_id]} OR away_team_id = #{params[:team_id]}")
    @user_team = Team.find_by(user_id: current_user, league_id: @league)

    respond_to do |format|
      format.json { render json: @team }
      format.html
    end
  end
end