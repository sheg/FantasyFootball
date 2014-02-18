require 'composite_primary_keys'

class Starter < ActiveRecord::Base
  self.primary_keys = [ :team_id, :week, :player_id ]
end
