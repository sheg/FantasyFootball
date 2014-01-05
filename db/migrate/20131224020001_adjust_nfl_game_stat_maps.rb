class AdjustNflGameStatMaps < ActiveRecord::Migration
  def up
    execute "DROP TRIGGER IF EXISTS `nfl_game_stat_maps_BINS`"
    execute "DROP TRIGGER IF EXISTS `nfl_game_stat_maps_BUPD`"

    execute "alter table nfl_game_stat_maps modify created_at timestamp default '0000-00-00 00:00:00'"
    execute "alter table nfl_game_stat_maps modify updated_at timestamp default now() on update now()"
  end

  def down

  end
end
