class NflSeason < ActiveRecord::Base
  has_many :games, class_name: NflGame, foreign_key: :season_id
  has_many :players, -> { uniq }, class_name: NflPlayer, foreign_key: :nfl_player_id, through: :games
end
