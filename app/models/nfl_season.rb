class NflSeason < ActiveRecord::Base
  has_many :games, class_name: NflGame, foreign_key: :season_id
  has_many :players, -> { uniq }, class_name: NflPlayer, foreign_key: :nfl_player_id, through: :games

  def self.[](s)
    NflSeason.find_by(year: s)
  end

  def get_full_season_name(season_type_id)
    "#{year}#{NflSeason.get_season_type_name(season_type_id)}"
  end

  def self.get_season_type_name(season_type_id)
    case season_type_id
      when 1, nil
        "REG"
      when 2
        "PRE"
      when 3
        "POST"
    end
  end
end
