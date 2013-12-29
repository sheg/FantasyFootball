module ApplicationHelper

  def highlight_my_team(my_teams, team)
    if signed_in?
      'highlight' if my_teams.include? team
    end
  end

  def recognize_my_league(my_leagues, league)
    if signed_in?
      'highlight' if my_leagues.include? league
    end
  end
end