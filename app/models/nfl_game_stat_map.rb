require 'rubygems'
require 'composite_primary_keys'

class NflGameStatMap < ActiveRecord::Base
  self.primary_keys = [ :nfl_game_player_id, :stat_type_id ]

  belongs_to :game_player, class_name: NflGamePlayer, foreign_key: :nfl_game_player_id
  belongs_to :stat_type, class_name: StatType, foreign_key: :stat_type_id

  has_one :game, class_name: NflGame, through: :game_player
  has_one :player, class_name: NflPlayer, through: :game_player
  has_one :team, class_name: NflTeam, through: :game_player
  has_one :position, class_name: NflPosition, through: :game_player
  has_one :season, class_name: NflSeason, through: :game

  scope :for_season_week, ->(s, w) { joins(:season).where('year = ? and week = ?', s, w) }
end
