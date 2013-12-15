class AddNflPlayers < ActiveRecord::Migration
  def change
    add_column :nfl_players, :photo_url, :string
    add_column :nfl_players, :external_player_id, :string
    add_index :nfl_players, :external_player_id

    add_column :nfl_season_team_players, :player_number, :integer
  end
end
