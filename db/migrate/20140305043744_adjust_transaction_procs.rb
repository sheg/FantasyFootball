class AdjustTransactionProcs < ActiveRecord::Migration
  def up
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
        declare league_week integer;

        declare TransCursor cursor for
          select nfl_player_id, from_team_id, to_team_id
          from team_transactions tt
            inner join leagues l on tt.league_id = l.id
          where
            (TeamId is null or (from_team_id = TeamId or to_team_id = TeamId))
            and (transaction_date < date_add(l.start_week_date, interval (adjusted_week - nfl_start_week + 1) Week))
            and tt.transaction_status_id = 1
          order by transaction_date, tt.id
        ;

        DECLARE CONTINUE HANDLER FOR NOT FOUND SET no_more_rows = TRUE;

        set adjusted_week = NflWeek;
        if SeasonTypeId = 2 then set adjusted_week = adjusted_week - 5; end if;
        if SeasonTypeId = 3 then set adjusted_week = adjusted_week + 17; end if;

        drop table if exists temp_roster_player_ids;
        create temporary table temp_roster_player_ids (team_id integer, player_id integer, started bool);

        set no_more_rows = false;
        open TransCursor;

        trans_loop: loop
          fetch TransCursor into _nfl_player_id, _from_team_id, _to_team_id;
          if no_more_rows then
            leave trans_loop;
          end if;

          if _to_team_id > 0 then
            insert into temp_roster_player_ids (team_id, player_id, started) select _to_team_id, _nfl_player_id, false;
          end if;

          if _from_team_id > 0 then
            delete from temp_roster_player_ids where team_id = _from_team_id and player_id = _nfl_player_id;
          end if;
        end loop;

        close TransCursor;

        select adjusted_week - l.nfl_start_week + 1 into league_week
        from leagues l
          inner join teams t on l.id = t.league_id and t.id = TeamId
        ;

        update temp_roster_player_ids temp, teams t, leagues l, starters s
        set temp.started = true
        where
          temp.team_id = s.team_id and temp.player_id = s.player_id
          and t.id = temp.team_id and l.id = t.league_id
          and s.team_id = t.id and s.active = true
          and s.week = adjusted_week - l.nfl_start_week + 1
        ;

        if ReturnResults then select distinct * from temp_roster_player_ids order by team_id, player_id; end if;
      END
    "
  end

  def down
    execute "DROP PROCEDURE IF EXISTS GetTeamRoster;"
  end
end
