class NflGame < ActiveRecord::Base
  belongs_to :home_team, class_name: NflTeam, foreign_key: :home_team_id
  belongs_to :away_team, class_name: NflTeam, foreign_key: :away_team_id
  belongs_to :season, class_name: NflSeason, foreign_key: :season_id

  has_many :stats, class_name: NflGameStatMap, foreign_key: :nfl_game_id
  has_many :players, -> { uniq }, through: :stats, foreign_key: :nfl_player_id

  def self.[](s)
    items = NflGame.find_by(external_game_id: s)
  end

  def attributes
    super.merge('description' => self.description)
  end

  def description
    start_time = Date.parse('1/1/1973') unless start_time
    "Week #{week}: #{away_team.abbr} @#{home_team.abbr} #{start_time.strftime('%m/%d/%Y %I:%M%p')}" if home_team
  end

  def self.by_week
    find :all, order: :week
  end

  scope :with_teams, -> { includes(:home_team, :away_team) }
end
