class CreateLeaguePayouts < ActiveRecord::Migration
  def up
    drop_table :league_payouts if table_exists? :league_payouts

    create_table :league_payouts do |t|
      t.integer :league_id
      t.integer :payout_type_id
      t.integer :rank
      t.decimal :percent, precision: 10, scale: 2, null: false, default: 0
      t.string :display_name

      t.timestamps
    end

    add_index :league_payouts, [ :league_id, :payout_type_id, :rank ], name: 'uq_league_payouts_league_type_rank', unique: true
  end

  def down
    drop_table :league_payouts if table_exists? :league_payouts
  end
end
