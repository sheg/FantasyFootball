class NflGamePlayer < ActiveRecord::Base
  belongs_to :game, class_name: NflGame, foreign_key: :nfl_game_id
  belongs_to :player, class_name: NflPlayer, foreign_key: :nfl_player_id
  belongs_to :team, class_name: NflTeam, foreign_key: :nfl_team_id
  belongs_to :position, class_name: NflPosition, foreign_key: :nfl_position_id

  has_one :season, class_name: NflSeason, through: :game
  has_many :stats, class_name: NflGameStatMap, foreign_key: :nfl_game_player_id

  default_scope { joins(:position, :season).includes(:position, :season) }
  scope :find_position, -> (p) { where(nfl_positions: { abbr: p }) }
  scope :find_player, -> (p) { includes(:player).where(nfl_player_id: p) }
  scope :find_year, -> (y) { joins(:season).where(nfl_seasons: { year: y } ) }
  scope :find_year_week, -> (y, w) { joins(:season, :game).where(nfl_seasons: { year: y }, nfl_games: { week: w } ) }
  scope :find_games, -> (g) { where(nfl_game_id: g) }

  #def attributes
  #  super.merge('position_abbr' => position_abbr)
  #end

  def position_abbr
    position.abbr
  end
end
