class AddWinnerToGames < ActiveRecord::Migration
  def up
    remove_column :games, :winner_id if column_exists? :games, :winner_id
    add_column :games, :winner_id, :integer

    execute "DROP TRIGGER IF EXISTS `games_set_winner`"
    execute "
      CREATE TRIGGER games_set_winner BEFORE UPDATE ON games
      FOR EACH ROW BEGIN
        DECLARE winner_id integer;
        SET winner_id = 0;
        IF NEW.home_score > NEW.away_score THEN
          SET winner_id = NEW.home_team_id;
        ELSEIF NEW.home_score < NEW.away_score THEN
          SET winner_id = NEW.away_team_id;
        END IF;

        SET NEW.winner_id = winner_id;
      END;
    ";
  end

  def down
    execute "DROP TRIGGER IF EXISTS `games_set_winner`"
    remove_column :games, :winner_id
  end
end
