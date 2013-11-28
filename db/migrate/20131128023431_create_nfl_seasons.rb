class CreateNflSeasons < ActiveRecord::Migration
  def change
    create_table :nfl_seasons do |t|
      t.integer :year
      t.string :name

      t.timestamps
    end
  end
end
