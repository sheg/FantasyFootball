class CreateNflGamePlayers < ActiveRecord::Migration
  def change
    create_table :nfl_game_players do |t|
      t.integer :nfl_game_id
      t.integer :nfl_player_id
      t.integer :nfl_team_id
      t.integer :nfl_position_id

      t.timestamps
    end
  end
end
