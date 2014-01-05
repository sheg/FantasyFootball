class AddSeasonTypeToNflGame < ActiveRecord::Migration
  def change
    add_column :nfl_games, :season_type_id, :integer
  end
end
