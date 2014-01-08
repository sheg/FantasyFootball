class NflPosition < ActiveRecord::Base
  has_many :nfl_position_stats
  has_many :stat_types, through: :nfl_position_stats

  def self.[](s)
    NflPosition.find_by(abbr: s)
  end

  scope :get_players, -> (position, year, season_type_id, week) {

  }
end
