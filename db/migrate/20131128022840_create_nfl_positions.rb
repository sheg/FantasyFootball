class CreateNflPositions < ActiveRecord::Migration
  def change
    create_table :nfl_positions do |t|
      t.string :name
      t.string :abbr

      t.timestamps
    end
  end
end
