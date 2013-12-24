class AddLeaguePointRules < ActiveRecord::Migration
  def change
    add_column :league_point_rules, :min_range, :decimal, precision: 10, scale: 4, default: 0, null: false
    add_column :league_point_rules, :max_range, :decimal, precision: 10, scale: 4, default: 0, null: false
    add_column :league_point_rules, :fixed_points, :decimal, precision: 10, scale: 4, default: 0, null: false

    add_index :league_point_rules, [ :league_id, :stat_type_id, :min_range, :max_range ], name: 'uq_league_point_rules', unique: true
  end
end
