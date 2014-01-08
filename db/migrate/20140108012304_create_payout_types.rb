class CreatePayoutTypes < ActiveRecord::Migration
  def change
    create_table :payout_types do |t|
      t.string :name
      t.string :display_name

      t.timestamps
    end

    add_index :payout_types, :name, unique: true
  end
end
