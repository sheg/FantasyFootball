class TeamsController < ApplicationController
  include TeamHelper

  before_action :find_team_and_league, except: [:schedule]
  before_action :get_current_week, except: [:destroy]

  def show
    @user_team = Team.includes([:user, :league]).find_by(user_id: current_user, league_id: @league)
    redirect_to(leagues_path, notice: "You are not part of this league") unless @user_team

    if @league.started?
      team = Team.includes(:league).find_by(id: params[:team_id])
      @roster_data = team.get_league_week_stats(@current_week.to_i)

      current_standings = TeamStanding.for_league_week(@league.id, @current_week)
      @team_standing = current_standings.find_by(team_id: params[:team_id])

    else
      redirect_to(@league, notice: "No team yet - Please execute a draft first")
    end
    render partial: "weekly_roster" if params[:use_json]
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

    #used for team info panel partial
    @teams = @league.teams.to_a
    team_index = @teams.find_index(@user_team)
    @teams.insert(0, @teams.delete_at(team_index))

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
      team_id = params[:team_id]
      if team_id
        @team = Team.includes([:league, :user]).find_by(id: params[:team_id])
      else
        @team = Team.includes([:user, :league]).find_by(user_id: current_user, league_id: params[:league_league_id])
      end
      @league = @team.league
    end

    def find_games_and_user_team
      render text: "No Team Found..." unless @team
      @games = Game.includes([:home_team, :away_team]).where("home_team_id = #{@team.id} OR away_team_id = #{@team.id}")
      @user_team = Team.includes([:user, :league]).find_by(user_id: current_user, league_id: @league)
    end

    def get_current_week
      find_team_and_league
      render text: "Current league is not set..." unless @league

      @current_week = params[:current_week]

      unless @current_week
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
end