class StatType < ActiveRecord::Base
  has_many :nfl_position_stats
  has_many :nfl_positions, through: :nfl_position_stats

  def self.[](s)
    StatType.find_by(name: s)
  end
end
