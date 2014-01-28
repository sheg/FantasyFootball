class CreateTeamPoints < ActiveRecord::Migration
  def change
    create_table :team_points do |t|
      t.integer :team_id
      t.integer :league_week
      t.integer :nfl_week
      t.decimal :points, precision: 10, scale: 4, null: false, default: 0

      t.timestamps
    end
  end
end
