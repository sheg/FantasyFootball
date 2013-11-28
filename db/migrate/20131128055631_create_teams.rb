class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.integer :league_id
      t.integer :user_id
      t.string :name
      t.timestamps
    end
    add_index :teams, :league_id
    add_index :teams, :user_id
  end
end