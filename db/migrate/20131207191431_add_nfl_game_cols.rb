class AddNflGameCols < ActiveRecord::Migration
  def change
    add_column :nfl_games, :away_score_q1, :integer
    add_column :nfl_games, :away_score_q2, :integer
    add_column :nfl_games, :away_score_q3, :integer
    add_column :nfl_games, :away_score_q4, :integer
    add_column :nfl_games, :away_score_ot, :integer
    add_column :nfl_games, :home_score_q1, :integer
    add_column :nfl_games, :home_score_q2, :integer
    add_column :nfl_games, :home_score_q3, :integer
    add_column :nfl_games, :home_score_q4, :integer
    add_column :nfl_games, :home_score_ot, :integer
    add_column :nfl_games, :has_started, :boolean
    add_column :nfl_games, :has_started_q1, :boolean
    add_column :nfl_games, :has_started_q2, :boolean
    add_column :nfl_games, :has_started_q3, :boolean
    add_column :nfl_games, :has_started_q4, :boolean
    add_column :nfl_games, :is_overtime, :boolean
    add_column :nfl_games, :is_over, :boolean
    add_column :nfl_games, :is_in_progress, :boolean

    remove_column :nfl_games, :quarter
    add_column :nfl_games, :quarter, :string

    remove_column :nfl_games, :time_remaining
    add_column :nfl_games, :time_remaining, :string

    remove_column :nfl_games, :yards_to_go
    add_column :nfl_games, :yards_to_go, :string

    rename_column :nfl_games, :posession, :possession
    rename_column :nfl_games, :yardline, :yard_line

    add_column :nfl_games, :season_id, :integer
  end
end
