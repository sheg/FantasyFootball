class NflPosition < ActiveRecord::Base
  def self.[](s)
    NflPosition.find_by(abbr: s)
  end

  def get_players(position_id, season, week)
  end
end
