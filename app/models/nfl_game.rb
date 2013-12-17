class NflGame < ActiveRecord::Base
  belongs_to :home_team, class_name: NflTeam, foreign_key: :home_team_id
  belongs_to :away_team, class_name: NflTeam, foreign_key: :away_team_id
  has_many :stats, class_name: NflGameStats, foreign_key: :game_id
end
