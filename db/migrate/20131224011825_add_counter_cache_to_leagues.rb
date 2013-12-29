class AddCounterCacheToLeagues < ActiveRecord::Migration
  def self.up
    add_column :leagues, :teams_count, :integer, default: 0
    League.find_each do |league|
      league.update_attribute(:teams_count, league.teams.length)
      league.save
    end
  end

  def self.down
    remove_column :leagues, :teams_count
  end
end