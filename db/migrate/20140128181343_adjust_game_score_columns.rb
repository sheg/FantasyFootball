class AdjustGameScoreColumns < ActiveRecord::Migration
  def change
    execute 'update games set home_score = 0, away_score = 0'
    change_column :games, :home_score, :decimal, precision: 10, scale: 4, null: false, default: 0
    change_column :games, :away_score, :decimal, precision: 10, scale: 4, null: false, default: 0
  end
end
