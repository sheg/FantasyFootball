class AddExternalGameIdToNflGames < ActiveRecord::Migration
  def change
    add_column :nfl_games, :external_game_id, :string
    add_index :nfl_games, :external_game_id
  end
end
