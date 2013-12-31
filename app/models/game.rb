class Game < ActiveRecord::Base
  belongs_to :home_team, class_name: Team, foreign_key: :home_team_id
  belongs_to :away_team, class_name: Team, foreign_key: :away_team_id

  has_many :player_stats, class_name: NflSeasonTeamPlayer, foreign_key: :game_id
  has_one :league

end