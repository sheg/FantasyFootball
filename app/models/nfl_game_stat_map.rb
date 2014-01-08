require 'rubygems'
require 'composite_primary_keys'

class NflGameStatMap < ActiveRecord::Base
  self.primary_keys = [ :nfl_game_player_id, :stat_type_id ]
  default_scope { includes :stat_type }

  belongs_to :game_player, class_name: NflGamePlayer, foreign_key: :nfl_game_player_id
  belongs_to :stat_type, class_name: StatType, foreign_key: :stat_type_id

  has_one :game, class_name: NflGame, through: :game_player
  has_one :player, class_name: NflPlayer, through: :game_player
  has_one :team, class_name: NflTeam, through: :game_player
  has_one :position, class_name: NflPosition, through: :game_player
  has_one :season, class_name: NflSeason, through: :game

  scope :find_player, -> (p) { joins(:game_player).where(game_players_nfl_game_stat_maps: { nfl_player_id: p } ) }
  scope :find_year, -> (y, st) { joins(:season, :game).where(nfl_seasons: { year: y }, nfl_games: { season_type_id: st }) }
  scope :find_year_week, -> (y, st, w) { joins(:season, :game).where(nfl_seasons: { year: y }, nfl_games: { week: w, season_type_id: st } ) }
  scope :find_games, -> (g) { joins(:game_player).where(nfl_game_players: { nfl_game_id: g }) }

  def attributes
    value = super
    value = value.merge('stat_type_name' => self.stat_type_name) if association(:stat_type).loaded?
    value
  end

  def stat_type_name
    stat_type.name
  end
end
