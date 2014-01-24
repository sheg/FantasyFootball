class CreateTeamTransactions < ActiveRecord::Migration
  def change
    create_table :team_transactions do |t|
      t.integer :league_id
      t.integer :from_team_id, null: false, default: 0
      t.integer :to_team_id, null: false, default: 0
      t.integer :nfl_player_id
      t.integer :activity_type_id
      t.datetime :transaction_date
      t.integer :draft_round
      t.integer :draft_pick

      t.timestamps
    end

    add_index :team_transactions, [ :league_id, :from_team_id, :to_team_id ], name: 'ix_team_transactions_league_from_to'
  end
end
