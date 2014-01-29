class NflPlayer < ActiveRecord::Base
  has_many :season_teams, class_name: NflSeasonTeamPlayer, foreign_key: :player_id
  has_many :game_players, class_name: NflGamePlayer, foreign_key: :nfl_player_id
  has_many :news, class_name: NflPlayerNews, foreign_key: :nfl_player_id
  has_many :injuries, class_name: NflPlayerInjury, foreign_key: :nfl_player_id

  has_many :games, class_name: NflGame, through: :game_players
  has_many :teams, class_name: NflTeam, through: :game_players
  has_many :positions, class_name: NflPosition, through: :game_players
  has_many :stats, class_name: NflGameStatMap, through: :game_players

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.[](s)
    NflPlayer.find_by(external_player_id: s)
  end

  #def attributes
  #  super.merge(
  #    news: self.news.to_a,
  #    injuries: self.injuries.to_a
  #  )
  #end

  scope :find_position, -> (p) { uniq.joins(game_players: [ :position, :team ]).where(nfl_positions: { abbr: p }) }
  scope :find_team, -> (t) { uniq.joins(game_players: [ :position, :team ]).where(nfl_teams: { abbr: t }) }
  scope :sort_last_name, -> { order(:last_name) }

  def get_week_order(season_type_id, week)
    week_order = 0
    if(season_type_id == 2)
      week_order = 10
    else
      week_order = season_type_id * 100
    end
    week_order += week
  end

  def get_latest_game(season_type_id, week)
    week_order = get_week_order(season_type_id, week)
    self.game_players.where('nfl_games.week_order <= ?', week_order).order('nfl_games.week_order desc').first
  end

  def team_for_week(season_type_id, week)
    get_latest_game(season_type_id, week).team
  end

  def position_for_week(season_type_id, week)
    get_latest_game(season_type_id, week).position
  end
end
