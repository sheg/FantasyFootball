class AddLeagueWeekColumns < ActiveRecord::Migration
  def change
    add_column :leagues, :nfl_start_week, :integer
    add_column :leagues, :start_week_date, :date
  end
end
