class AddPositionSortOrder < ActiveRecord::Migration
  def change
    add_column :nfl_positions, :sort_order, :integer
  end
end
