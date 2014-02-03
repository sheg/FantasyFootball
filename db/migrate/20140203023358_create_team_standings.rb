class CreateTeamStandings < ActiveRecord::Migration
  def up
    execute "DROP TABLE IF EXISTS team_standings;"

    create_table :team_standings, id: false do |t|
      t.integer :team_id
      t.integer :week
      t.string :result
      t.integer :wins, null: false, default: 0
      t.integer :losses, null: false, default: 0
      t.integer :ties, null: false, default: 0
      t.decimal :percent, precision: 10, scale: 4, null: false, default: 0
      t.integer :games_back, null: false, default: 0
      t.string :streak
      t.decimal :points_for, precision: 10, scale: 4, null: false, default: 0
      t.decimal :points_against, precision: 10, scale: 4, null: false, default: 0

      t.timestamps
    end

    execute "ALTER TABLE team_standings ADD PRIMARY KEY(team_id, week);"

    execute "
      CREATE TRIGGER team_standings_percent_insert BEFORE INSERT ON team_standings
      FOR EACH ROW BEGIN
        IF NEW.wins > 0 or NEW.losses > 0 THEN
          SET NEW.percent = NEW.wins / (NEW.wins + NEW.losses + NEW.ties);
        END IF;
      END;
    ";

    execute "
      CREATE TRIGGER team_standings_percent_update BEFORE UPDATE ON team_standings
      FOR EACH ROW BEGIN
        IF NEW.wins > 0 or NEW.losses > 0 THEN
          SET NEW.percent = NEW.wins / (NEW.wins + NEW.losses + NEW.ties);
        END IF;
      END;
    ";

    execute "DROP PROCEDURE IF EXISTS PopulateTeamStandings;"
    execute "
      CREATE PROCEDURE PopulateTeamStandings(
      )
      BEGIN
        declare current_week integer;

        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
          ROLLBACK;
        END;

        START TRANSACTION;

        set current_week = 1;

        while current_week <= 21 do
          delete from team_standings
          where week = current_week;

          insert into team_standings (team_id, week, wins, losses, ties, points_for, points_against, created_at, updated_at)
          select t.id,
            current_week,
            sum(case winner_id = t.id when true then 1 else 0 end) as wins,
            sum(case winner_id != t.id when true then 1 else 0 end) as losses,
            sum(case winner_id = 0 when true then 1 else 0 end) as ties,
            sum(case g.home_team_id = t.id when true then g.home_score else g.away_score end) as points_for,
            sum(case g.home_team_id != t.id when true then g.home_score else g.away_score end) as points_against,
            utc_timestamp() as created_at,
            utc_timestamp() as updated_at
          from games g
            inner join teams t on (g.home_team_id = t.id or g.away_team_id = t.id)
            inner join team_points tp on t.id = tp.team_id and g.week = tp.league_week
            inner join leagues l on t.league_id = l.id and (l.weeks + l.playoff_weeks >= current_week)
          where g.week <= current_week
          group by t.id
          order by wins desc, losses
          ;

          set current_week = current_week + 1;
        end while;

        update team_standings ts, games g
        set result = case g.winner_id when 0 then 'T' when ts.team_id then 'W' else 'L' end
        where ts.team_id in (g.home_team_id, g.away_team_id) and ts.week = g.week;

        update team_standings ts,
          (
            select
              team_id, week,
              concat(StreakSet.Result, MAX( StreakSet.WinLossStreak )) as streak
            from
              (
                select YR.team_id, YR.week,
                   @CurStatus := YR.result COLLATE utf8_general_ci as Result,
                   @WinLossSeq := if(@CurStatus = @LastStatus, @WinLossSeq +1, 1 ) as WinLossStreak,
                  #1 as WinLossStreak,
                   @LastStatus := @CurStatus as carryOverForNextRecord
                from
                   team_standings YR,
                   ( select @CurStatus := '',
                      @LastStatus := '',
                      @WinLossSeq := 0 COLLATE latin1_general_ci  ) sqlvars
                order by
                   YR.team_id, YR.week
              ) StreakSet
            group by team_id, week, StreakSet.Result
          ) streaks
        set ts.streak = streaks.streak
        where ts.team_id = streaks.team_id and ts.week = streaks.week
        ;

        update team_standings ts,
          (
            select ts.team_id, ts.week, ts.wins, lw.max_wins, lw.max_wins - ts.wins as games_back
            from team_standings ts
              inner join teams t on ts.team_id = t.id
              inner join leagues l on t.league_id = l.id
              inner join (
                select l.id as league_id, ts.week, max(ts.wins) as max_wins
                from team_standings ts
                  inner join teams t on ts.team_id = t.id
                  inner join leagues l on t.league_id = l.id
                group by l.id, ts.week
              ) lw on l.id = lw.league_id and ts.week = lw.week
          ) stats
        set ts.games_back = stats.games_back
        where ts.team_id = stats.team_id and ts.week = stats.week
        ;

        COMMIT;
      end;
    ";
  end

  def down
    def down
      execute "DROP TRIGGER IF EXISTS `team_standings_percent_update`"
      execute "DROP TRIGGER IF EXISTS `team_standings_percent_insert`"
      execute "DROP PROCEDURE IF EXISTS PopulateTeamStandings;"
      drop_table :team_standings
    end
  end
end
