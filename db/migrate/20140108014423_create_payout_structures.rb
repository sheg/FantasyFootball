class CreatePayoutStructures < ActiveRecord::Migration
  def change
    create_table :payout_structures do |t|
      t.string :name
      t.string :display_name
      t.integer :payout_type_id
      t.integer :rank
      t.decimal :percent, precision: 10, scale: 2

      t.timestamps
    end

    add_index :payout_structures, :name, unique: true
  end
end
