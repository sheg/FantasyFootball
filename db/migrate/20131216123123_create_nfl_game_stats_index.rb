class CreateNflGameStatsIndex < ActiveRecord::Migration
  def change
    add_index :nfl_game_stats, [ :nfl_game_id, :nfl_player_id ]
  end
end
