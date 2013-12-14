class CreateRosters < ActiveRecord::Migration
  def change
    create_table :rosters do |t|
      t.integer :league_team_id
      t.integer :nfl_player_id
      t.boolean :is_active
      t.timestamps
    end
  end
end