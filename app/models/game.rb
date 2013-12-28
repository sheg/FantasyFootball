class Game < ActiveRecord::Base
  has_many :player_stats, class_name: NflSeasonTeamPlayer, foreign_key: :game_id


end