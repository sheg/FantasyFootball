class GamesAddWeekOrder < ActiveRecord::Migration
  def up
    add_column :nfl_games, :week_order, :integer

    execute "
      CREATE TRIGGER nfl_games_week_order_update BEFORE UPDATE ON nfl_games
      FOR EACH ROW BEGIN
        SET NEW.week_order = case NEW.season_type_id when 2 then 10 else NEW.season_type_id * 100 end + NEW.week;
      END;
    ";

    execute "update nfl_games set week = week where id > 0";
  end

  def down
    execute "DROP TRIGGER IF EXISTS `nfl_games_week_order_update`"

    remove_column :nfl_games, :week_order
  end
end
