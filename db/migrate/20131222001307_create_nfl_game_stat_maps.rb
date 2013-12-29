class CreateNflGameStatMaps < ActiveRecord::Migration
  def up
    drop_table :nfl_game_stats if table_exists? :nfl_game_stats
    drop_table :nfl_game_stat_maps if table_exists? :nfl_game_stat_maps

    create_table :nfl_game_stat_maps, id: false do |t|
      t.integer :nfl_game_player_id
      t.integer :stat_type_id
      t.decimal :value, precision: 10, scale: 4

      t.timestamps
    end

    add_index :nfl_games, [ :season_id, :week ] unless index_exists? :nfl_games, [ :season_id, :week ]

    execute "ALTER TABLE nfl_game_stat_maps ADD PRIMARY KEY(nfl_game_player_id, stat_type_id);"
  end

  def down
    drop_table :nfl_game_stat_maps
  end
end
