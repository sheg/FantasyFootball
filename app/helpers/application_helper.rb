module ApplicationHelper

  def highlight_my_team(my_teams, team)
    if signed_in?
      'highlight' if my_teams.include? team
    end
  end
end