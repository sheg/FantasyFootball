class CreateStarters < ActiveRecord::Migration
  def up
    execute "DROP TABLE IF EXISTS starters;"

    create_table :starters, id: false do |t|
      t.integer :team_id
      t.integer :week
      t.integer :player_id
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    execute "ALTER TABLE starters ADD PRIMARY KEY(team_id, week, player_id);"
  end

  def down
    execute "DROP TABLE IF EXISTS starters;"
  end
end
