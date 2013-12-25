class NflGamePlayer < ActiveRecord::Base
  belongs_to :game, class_name: NflGame, foreign_key: :nfl_game_id
  belongs_to :player, class_name: NflPlayer, foreign_key: :nfl_player_id
  belongs_to :team, class_name: NflTeam, foreign_key: :nfl_team_id
  belongs_to :position, class_name: NflPosition, foreign_key: :nfl_position_id
  has_one :season, class_name: NflSeason, through: :game
  has_many :stats, class_name: NflGameStatMap, foreign_key: :nfl_game_player_id
end
