class CreateRosterActivities < ActiveRecord::Migration
  def change
    create_table :roster_activities do |t|
      t.integer :roster_id
      t.integer :activity_type_id
      t.datetime :activity_date

      t.timestamps
    end
  end
end
