class NflGame < ActiveRecord::Base
  belongs_to :home_team, class_name: NflTeam, foreign_key: :home_team_id
  belongs_to :away_team, class_name: NflTeam, foreign_key: :away_team_id
  belongs_to :season, class_name: NflSeason, foreign_key: :season_id

  has_many :stats, class_name: NflGameStatMap, foreign_key: :nfl_game_id
  has_many :players, -> { uniq }, through: :stats, foreign_key: :nfl_player_id

  def self.[](s)
    items = NflGame.find_by(external_game_id: s)
  end
end
