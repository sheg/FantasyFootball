class CreateNflGameStats < ActiveRecord::Migration
  def change
    create_table :nfl_game_stats do |t|
      t.integer :nfl_game_id
      t.integer :nfl_player_id
      t.integer :passing_yards
      t.integer :interceptions

      t.timestamps
    end
  end
end
