class NflGame < ActiveRecord::Base
  belongs_to :home_team, class_name: NflTeam, foreign_key: :home_team_id
  belongs_to :away_team, class_name: NflTeam, foreign_key: :away_team_id
  belongs_to :season, class_name: NflSeason, foreign_key: :season_id

  has_many :game_players, class_name: NflGamePlayer, foreign_key: :nfl_game_id
  has_many :stats, class_name: NflGameStatMap, through: :game_players
  has_many :players, class_name: NflPlayer, through: :game_players

  def self.[](s)
    items = NflGame.find_by(external_game_id: s)
  end

  #def attributes
  #  super.merge('description' => description)
  #end

  def description
    "Season #{season.get_full_season_name(season_type_id)} Week #{week}: #{away_team.abbr} @#{home_team.abbr} #{start_time.strftime('%m/%d/%Y %I:%M%p')}" if home_team
  end

  def self.sort_by_week
    find :all, order: :week
  end

  default_scope { includes(:season) }
  scope :with_teams, -> { includes(:home_team, :away_team) }
  scope :find_season, -> (s) { where(nfl_seasons: { year: s }) }
  scope :find_season_week, -> (s, w) { where(nfl_seasons: { year: s }, week: w) }
  scope :find_team, -> (t) {
    with_teams.joins('INNER JOIN nfl_teams t on (t.id = home_team_id or t.id = away_team_id)')
      .where('t.abbr = ?', t).order(:season_type_id, :week)
  }
end
