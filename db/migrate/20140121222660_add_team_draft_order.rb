class AddTeamDraftOrder < ActiveRecord::Migration
  def change
    add_column :teams, :draft_order, :integer
    add_column :leagues, :draft_start_date, :datetime
  end
end
