class AddStatusToTeamTransaction < ActiveRecord::Migration
  def up
    add_column :team_transactions, :transaction_status_id, :integer, null: false, default: 1
    add_column :team_transactions, :group_id, :string
  end

  def down
    remove_column :team_transactions, :transaction_status_id if column_exists? :team_transactions, :transaction_status_id
    remove_column :team_transactions, :group_id if column_exists? :team_transactions, :group_id
  end
end
