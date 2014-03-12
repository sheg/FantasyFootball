class CreateTransactionStatuses < ActiveRecord::Migration
  def change
    create_table :transaction_statuses do |t|
      t.string :name
      t.string :display_name

      t.timestamps
    end
  end
end
