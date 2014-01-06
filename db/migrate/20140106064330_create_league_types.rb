class CreateLeagueTypes < ActiveRecord::Migration
  def change
    create_table :league_types do |t|
      t.string :name
      t.string :starting_slots_json
      t.string :position_limits_json

      t.timestamps
    end
  end
end
