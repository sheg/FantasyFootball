class CreateNflSeasonTeamPlayers < ActiveRecord::Migration
  def change
    create_table :nfl_season_team_players do |t|
      t.integer :season_id
      t.integer :team_id
      t.integer :player_id
      t.integer :position_id

      t.timestamps
    end
  end
end
