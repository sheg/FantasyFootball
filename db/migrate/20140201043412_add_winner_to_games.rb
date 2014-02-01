class AddWinnerToGames < ActiveRecord::Migration
  def up
    add_column :games, :winner_id, :integer

    execute "
      CREATE TRIGGER games_set_winner BEFORE UPDATE ON games
      FOR EACH ROW BEGIN
        SET NEW.winner_id = case home_score > away_score when true then NEW.home_team_id else NEW.away_team_id end;
      END;
    ";
  end

  def down
    execute "DROP TRIGGER IF EXISTS `games_set_winner`"
    remove_column :games, :winner_id
  end
end
