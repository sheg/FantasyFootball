require 'composite_primary_keys'

class TeamStanding < ActiveRecord::Base
  self.primary_keys = [ :team_id, :week ]

  belongs_to :team
  has_one :league, through: :team

  scope :for_league_week, ->(l, w) { joins(:team).where('week = ? and league_id = ?', w, l).order('percent desc') }

  def game
    Game.find_by("week = #{self.week} and (home_team_id = #{self.team_id} or away_team_id = #{self.team_id})")
  end
end
