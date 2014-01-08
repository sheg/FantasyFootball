require 'composite_primary_keys'

class NflPositionStat < ActiveRecord::Base
  self.primary_keys = [ :nfl_position_id, :stat_type_id ]
  belongs_to :nfl_position
  belongs_to :stat_type

  default_scope { order(:sort_order) }
end
