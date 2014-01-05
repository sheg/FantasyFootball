class AddNflGamePlayersPoints < ActiveRecord::Migration
  def change
    add_column :nfl_game_players, :points, :decimal, precision: 10, scale: 4, null: false, default: 0
  end
end
