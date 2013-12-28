class AddSchedule < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.integer :league_id
      t.integer :game_id

      t.timestamps
    end
  end
end
