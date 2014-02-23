require 'composite_primary_keys'

class Starter < ActiveRecord::Base
  self.primary_keys = [ :team_id, :week, :player_id ]

  belongs_to :player, class_name: NflPlayer, foreign_key: :player_id
  belongs_to :team, class_name: Team, foreign_key: :team_id
  has_one :league, through: :team

  def get_nfl_game
    nfl_week = league.get_nfl_week(week)
    player.game_for_week(nfl_week[:season_type_id], nfl_week[:week])
  end
end
