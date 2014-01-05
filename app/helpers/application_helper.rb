module ApplicationHelper

  def highlight_my_team(my_team, team)
    if signed_in? && my_team
      'highlight' if my_team.id == team.id
    end
  end
end