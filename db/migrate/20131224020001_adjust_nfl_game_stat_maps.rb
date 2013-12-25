class AdjustNflGameStatMaps < ActiveRecord::Migration
  def up
    execute 'alter table nfl_game_stat_maps modify created_at timestamp default CURRENT_TIMESTAMP'
    execute 'alter table nfl_game_stat_maps modify updated_at timestamp default CURRENT_TIMESTAMP'

    execute "DROP TRIGGER IF EXISTS `nfl_game_stat_maps_BINS`"
    execute "DROP TRIGGER IF EXISTS `nfl_game_stat_maps_BUPD`"
  end

  def down

  end
end
