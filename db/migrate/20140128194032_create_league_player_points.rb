class CreateLeaguePlayerPoints < ActiveRecord::Migration
  def change
    create_table :league_player_points do |t|
      t.integer :league_id
      t.integer :player_id
      t.integer :league_week
      t.integer :nfl_week
      t.decimal :points, precision: 10, scale: 4, null: false, default: 0

      t.timestamps
    end
  end
end
