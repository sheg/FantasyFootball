class AddLeagueDetailColumns < ActiveRecord::Migration
  def change
    add_column :leagues, :league_type_id, :integer
    add_column :leagues, :entry_amount, :decimal, precision: 10, scale: 2, null: false, default: 0
    add_column :leagues, :fee_percent, :decimal, precision: 10, scale: 2, null: false, default: 0
    add_column :leagues, :roster_count, :integer, null: false, default: 18
    add_column :leagues, :playoff_weeks, :integer, null: false, default: 3
    add_column :leagues, :teams_in_playoffs, :integer, null: false, default: 6
    add_column :leagues, :must_be_full, :boolean, null: false, default: true
    add_column :leagues, :max_roster_adjustments, :integer, null: false, default: 9999999
    add_column :leagues, :draft_dollars, :integer, null: false, default: 0
    add_column :leagues, :draft_pick_time, :integer, null: false, default: 120
    add_column :leagues, :draft_unique_players, :boolean, null: false, default: true
  end
end
