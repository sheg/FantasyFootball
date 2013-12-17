class NflPlayer < ActiveRecord::Base
  has_many :season_teams, class_name: NflSeasonTeamPlayer, foreign_key: :player_id
  has_many :stats, class_name: NflGameStats, foreign_key: :game_id

  def full_name
    "#{first_name} #{last_name}"
  end
end
