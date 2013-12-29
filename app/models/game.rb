class Game < ActiveRecord::Base
  has_many :player_stats, class_name: NflSeasonTeamPlayer, foreign_key: :game_id

  has_many :schedules
  has_many :leagues, through: :schedules

end