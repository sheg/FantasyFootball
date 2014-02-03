require 'composite_primary_keys'

class TeamStanding < ActiveRecord::Base
  self.primary_keys = [ :team_id, :week ]

  belongs_to :team
  belongs_to :league, through: :team
end
