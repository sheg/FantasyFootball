class AddLeagueVisibility < ActiveRecord::Migration
  def change
    add_column :leagues, :is_private, :boolean, null: false, default: false
  end
end
