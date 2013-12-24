class CreateLeaguePointRules < ActiveRecord::Migration
  def up
    create_table :league_point_rules do |t|
      t.integer :league_id
      t.integer :stat_type_id
      t.decimal :multiplier, precision: 10, scale: 4, null: false, default: 0

      t.timestamps
    end
  end

  def down
     drop_table :league_point_rules
  end
end
