class AddLeagueIdToGame < ActiveRecord::Migration
  def change
    add_column :games, :league_id, :integer
    add_index :games, :league_id

    add_column :leagues, :weeks, :integer, default: 13, null: false
  end
end