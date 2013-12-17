class AddNflTeamIndex < ActiveRecord::Migration
  def change
    add_index :nfl_teams, :abbr

    add_column :nfl_games, :season_id, :integer
  end
end
