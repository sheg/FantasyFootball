class CreateNflPositionStats < ActiveRecord::Migration
  def up
    drop_table :nfl_position_stats if table_exists? :nfl_position_stats

    create_table :nfl_position_stats, id: false do |t|
      t.integer :nfl_position_id
      t.integer :stat_type_id
      t.integer :sort_order

      t.timestamps
    end

    execute "ALTER TABLE nfl_position_stats ADD PRIMARY KEY(nfl_position_id, stat_type_id);"
  end

  def down
    drop_table :nfl_position_stats if table_exists? :nfl_position_stats
  end
end
