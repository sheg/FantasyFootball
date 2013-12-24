class AdjustNflGameStatMaps < ActiveRecord::Migration
  def up
    change_column_default :nfl_game_stat_maps, :created_at, Time.now
    change_column_default :nfl_game_stat_maps, :updated_at, Time.now

    execute "DROP TRIGGER IF EXISTS `nfl_game_stat_maps_BINS`"
    execute "DROP TRIGGER IF EXISTS `nfl_game_stat_maps_BUPD`"
  end

  def down

  end
end
