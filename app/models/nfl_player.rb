class NflPlayer < ActiveRecord::Base
  has_many :season_teams, class_name: NflSeasonTeamPlayer, foreign_key: :player_id
  has_many :game_players, class_name: NflGamePlayer, foreign_key: :nfl_player_id
  has_many :news, class_name: NflPlayerNews, foreign_key: :nfl_player_id

  has_many :games, class_name: NflGame, through: :game_players
  has_many :teams, class_name: NflTeam, through: :game_players
  has_many :positions, class_name: NflPosition, through: :game_players
  has_many :stats, class_name: NflGameStatMap, through: :game_players

  def full_name
    "#{first_name} #{last_name}"
  end
end
