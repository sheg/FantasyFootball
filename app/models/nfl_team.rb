class NflTeam < ActiveRecord::Base
  has_many :home_games, class_name: NflGame, foreign_key: :home_team_id
  has_many :away_games, class_name: NflGame, foreign_key: :away_team_id
  has_many :season_players, class_name: NflSeasonTeamPlayer, foreign_key: :team_id
end
