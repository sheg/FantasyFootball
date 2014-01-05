class AddNflTeamIndex < ActiveRecord::Migration
  def change
    add_index :nfl_teams, :abbr
  end
end
