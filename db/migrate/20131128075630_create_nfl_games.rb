class CreateNflGames < ActiveRecord::Migration
  def change
    create_table :nfl_games do |t|
      t.integer :week
      t.integer :home_team_id
      t.integer :away_team_id
      t.datetime :start_time
      t.integer :home_score
      t.integer :away_score
      t.integer :quarter
      t.boolean :posession
      t.integer :down
      t.integer :yards_to_go
      t.integer :yardline
      t.boolean :field_side
      t.timestamp :time_remaining

      t.timestamps
    end
    add_index :nfl_games, :home_team_id
    add_index :nfl_games, :away_team_id

  end
end