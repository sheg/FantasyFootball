require 'composite_primary_keys'

class LeaguePlayerPoint < ActiveRecord::Base
  self.primary_keys = [ :league_id, :season_type_id, :nfl_week, :player_id ]

  attr_accessor :stats
end
