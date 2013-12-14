class CreateLeagues < ActiveRecord::Migration
  def change
    create_table :leagues do |t|
      t.integer :season_id
      t.string :name
      t.integer :size
      t.timestamps
    end
    add_index :leagues, :season_id
  end
end
