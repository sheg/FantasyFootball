class CreatePayoutStructurePayouts < ActiveRecord::Migration
  def up
    drop_table :payout_structure_payouts if table_exists? :payout_structure_payouts

    create_table :payout_structure_payouts do |t|
      t.integer :payout_structure_id
      t.integer :payout_type_id
      t.integer :rank
      t.decimal :percent, precision: 10, scale: 2, null: false, default: 0
      t.string :display_name

      t.timestamps
    end

    add_index :payout_structure_payouts, [ :payout_structure_id, :payout_type_id, :rank ], name: 'uq_payout_structure_payouts_league_type_rank', unique: true
  end

  def down
    drop_table :payout_structure_payouts if table_exists? :payout_structure_payouts
  end
end
