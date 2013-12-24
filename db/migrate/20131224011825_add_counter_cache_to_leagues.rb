class AddCounterCacheToLeagues < ActiveRecord::Migration
  def change
    add_column :leagues, :teams_count, :integer
  end
end
