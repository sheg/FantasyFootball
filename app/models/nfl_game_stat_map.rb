require 'rubygems'
require 'composite_primary_keys'

class NflGameStatMap < ActiveRecord::Base
  self.primary_keys = [ :nfl_game_id, :nfl_player_id, :stat_type_id ]

  belongs_to :game, class_name: NflGame, foreign_key: :nfl_game_id
  belongs_to :player, class_name: NflPlayer, foreign_key: :nfl_player_id
  belongs_to :stat_type, class_name: StatType, foreign_key: :stat_type_id
  has_one :season, class_name: NflSeason, through: :game

  scope :for_season_week, ->(s, w) { joins(:season).where('year = ? and week = ?', s, w) }
end
