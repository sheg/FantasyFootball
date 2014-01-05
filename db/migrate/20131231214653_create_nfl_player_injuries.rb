class CreateNflPlayerInjuries < ActiveRecord::Migration
  def change
    drop_table :nfl_player_injuries if table_exists? :nfl_player_injuries

    create_table :nfl_player_injuries do |t|
      t.integer :nfl_player_id
      t.integer :external_injury_id
      t.datetime :injury_date
      t.string :body_part
      t.string :practice
      t.string :practice_description
      t.string :status
      t.integer :week

      t.timestamps
    end

    add_index :nfl_player_injuries, [ :nfl_player_id, :external_injury_id ], name: 'ix_nfl_player_injuries_player_external'
  end
end
