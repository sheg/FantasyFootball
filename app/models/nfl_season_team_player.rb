class NflSeasonTeamPlayer < ActiveRecord::Base
  belongs_to :team, class_name: NflTeam, foreign_key: :team_id
  belongs_to :season, class_name: NflSeason, foreign_key: :season_id
  belongs_to :position, class_name: NflPosition, foreign_key: :position_id
  belongs_to :player, class_name: NflPlayer, foreign_key: :player_id
end
