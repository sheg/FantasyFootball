class CreateTeamPoints < ActiveRecord::Migration
  def up
    execute "DROP TABLE IF EXISTS team_points;"

    create_table :team_points, id: false do |t|
      t.integer :team_id
      t.integer :league_week
      t.integer :season_type_id
      t.integer :nfl_week
      t.decimal :points, precision: 10, scale: 4, null: false, default: 0

      t.timestamps
    end

    execute "ALTER TABLE team_points ADD PRIMARY KEY(team_id, league_week);"

    execute "DROP PROCEDURE IF EXISTS GetTeamRoster;"
    execute "
      CREATE PROCEDURE GetTeamRoster(
        IN TeamId integer,
        IN SeasonTypeId integer,
        IN NflWeek integer,
        IN ReturnResults boolean
      )
      BEGIN
        declare _nfl_player_id, _from_team_id, _to_team_id integer;
        declare no_more_rows boolean;
        declare adjusted_week integer;

        declare TransCursor cursor for
          select nfl_player_id, from_team_id, to_team_id
          from team_transactions tt
            inner join leagues l on tt.league_id = l.id
          where
            (TeamId is null or (from_team_id = TeamId or to_team_id = TeamId))
            and (transaction_date < date_add(l.start_week_date, interval (adjusted_week - nfl_start_week + 1) Week))
          order by transaction_date
        ;

        DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows = TRUE;

        set adjusted_week = NflWeek;
        if SeasonTypeId = 2 then set adjusted_week = adjusted_week - 5; end if;
        if SeasonTypeId = 3 then set adjusted_week = adjusted_week + 17; end if;

        drop table if exists temp_roster_player_ids;
        create temporary table temp_roster_player_ids (team_id integer, player_id integer);

        set no_more_rows = false;
        open TransCursor;

        trans_loop: loop
          fetch TransCursor into _nfl_player_id, _from_team_id, _to_team_id;
          if no_more_rows then
            leave trans_loop;
          end if;

          if _to_team_id > 0 then
            insert into temp_roster_player_ids (team_id, player_id) select _to_team_id, _nfl_player_id;
          end if;

          if _from_team_id > 0 then
            delete from temp_roster_player_ids where team_id = _from_team_id and player_id = _nfl_player_id;
          end if;
        end loop;

        close TransCursor;

        if ReturnResults then select * from temp_roster_player_ids order by team_id, player_id; end if;
      END;
    "

    execute "DROP PROCEDURE IF EXISTS UpdateTeamPoints;"
    execute "
      CREATE PROCEDURE UpdateTeamPoints(
        IN TeamId integer,
        IN SeasonTypeId integer,
        IN NflWeek integer
      )
      BEGIN
        declare adjusted_week integer;

        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
          ROLLBACK;
        END;

        call GetTeamRoster(TeamId, SeasonTypeId, NflWeek, false);

        START TRANSACTION;

        set adjusted_week = NflWeek;
        if SeasonTypeId = 2 then set adjusted_week = adjusted_week - 5; end if;
        if SeasonTypeId = 3 then set adjusted_week = adjusted_week + 17; end if;

        delete from team_points
        where team_id in (select distinct team_id from temp_roster_player_ids)
          and season_type_id = SeasonTypeId
          and nfl_week = NflWeek
        ;

        insert into team_points (team_id, league_week, season_type_id, nfl_week, points, created_at, updated_at)
        select ids.team_id as team_id, adjusted_week - l.nfl_start_week + 1 as league_week, SeasonTypeId, NflWeek, coalesce(sum(lpp.points), 0), utc_timestamp(), utc_timestamp()
        from temp_roster_player_ids ids
          inner join league_player_points lpp on ids.player_id = lpp.player_id
          inner join teams t on ids.team_id = t.id
          inner join leagues l on l.id = t.league_id and (lpp.league_id = l.id or lpp.league_id is null)
        where
          (lpp.nfl_week = NflWeek and lpp.season_type_id = SeasonTypeId)
          and l.nfl_start_week <= adjusted_week
          and exists (select 1 from league_point_rules where league_id = l.id)
        group by ids.team_id
        ;

        insert into team_points (team_id, league_week, season_type_id, nfl_week, points, created_at, updated_at)
        select t.id as team_id, adjusted_week - l.nfl_start_week + 1 as league_week, g.season_type_id, g.week, sum(gp.points), utc_timestamp(), utc_timestamp()
        from nfl_game_players gp
          inner join temp_roster_player_ids ids on ids.player_id = gp.nfl_player_id
          inner join teams t on ids.team_id = t.id
          inner join leagues l on l.id = t.league_id
          inner join nfl_games g on g.id = gp.nfl_game_id
        where
          g.season_type_id = SeasonTypeId
          and g.week = NflWeek
          and l.nfl_start_week <= adjusted_week
          and not exists (select 1 from league_point_rules where league_id = l.id)
        group by t.id, NflWeek, g.season_type_id, g.week
        ;

        insert into team_points (team_id, league_week, season_type_id, nfl_week, points, created_at, updated_at)
        select ids.team_id, adjusted_week - l.nfl_start_week + 1 as league_week, SeasonTypeId, NflWeek, 0 as points, utc_timestamp(), utc_timestamp()
        from (select distinct team_id from temp_roster_player_ids) ids
          inner join teams t on ids.team_id = t.id
          inner join leagues l on l.id = t.league_id
        where
          not exists (select 1 from team_points where team_id = ids.team_id and season_type_id = SeasonTypeid and nfl_week = NflWeek)
          and l.nfl_start_week <= adjusted_week
        ;

        update games g
          inner join team_points tp on g.week = tp.league_week
        set g.home_score = tp.points
        where g.home_team_id = tp.team_id
        ;

        update games g
          inner join team_points tp on g.week = tp.league_week
        set g.away_score = tp.points
        where g.away_team_id = tp.team_id
        ;

        COMMIT;
      END;
    "
  end

  def down
    execute "DROP PROCEDURE IF EXISTS GetTeamRoster;"
    execute "DROP PROCEDURE IF EXISTS UpdateTeamPoints;"
    drop_table :team_points
  end
end
