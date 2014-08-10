class LoadLeaguePlayerPoints < ActiveRecord::Migration
  def up
    execute "DROP PROCEDURE IF EXISTS UpdateGamePlayerPoints;"
    execute "
      CREATE PROCEDURE UpdateGamePlayerPoints(
        IN SeasonId integer,
        IN SeasonTypeId integer,
        IN Week integer
      )
      BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
          ROLLBACK;
        END;

        START TRANSACTION;

        set SeasonId := coalesce(SeasonId, 0);
        set SeasonTypeId := coalesce(SeasonTypeId, 0);
        set Week := coalesce(Week, 0);

        update nfl_game_players ngp
          inner join nfl_games g on ngp.nfl_game_id = g.id
        set ngp.points = 0
        where
          (SeasonId <= 0 or g.season_id = SeasonId)
          and (SeasonTypeId <= 0 or g.season_type_id = SeasonTypeId)
          and (Week <= 0 or g.week = Week)
        ;

        update nfl_game_players gp,
          (
            select gp.id, sum(temp.points) as calc_points, gp.points
            from (
            select gp.id, gsm.value, lpr.fixed_points, lpr.multiplier, lpr.min_range, lpr.max_range,
              case lpr.fixed_points > 0 when true then lpr.fixed_points else gsm.value * lpr.multiplier end as points
            from nfl_game_stat_maps gsm
              inner join nfl_game_players gp on gsm.nfl_game_player_id = gp.id
              inner join nfl_games g on gp.nfl_game_id = g.id
              inner join league_point_rules lpr on lpr.stat_type_id = gsm.stat_type_id
              and ( (lpr.min_range = 0 and lpr.max_range = 0) or (gsm.value >= lpr.min_range and gsm.value <= lpr.max_range) )
              and lpr.league_id is null
            where
              (SeasonId <= 0 or g.season_id = SeasonId)
              and (SeasonTypeId <= 0 or g.season_type_id = SeasonTypeId)
              and (Week <= 0 or g.week = Week)
            ) temp
            inner join nfl_game_players gp on temp.id = gp.id
            group by gp.id, gp.points
          ) calc
        set gp.points = calc.calc_points
        where gp.id = calc.id
        ;

        COMMIT;
      END;
    "

    execute "DROP PROCEDURE IF EXISTS LoadLeaguePlayerPoints;"
    execute "
      CREATE PROCEDURE LoadLeaguePlayerPoints(
        IN SeasonId integer,
        IN SeasonTypeId integer,
        IN Week integer
      )
      BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
          ROLLBACK;
        END;

        START TRANSACTION;

        set SeasonId := coalesce(SeasonId, 0);
        set SeasonTypeId := coalesce(SeasonTypeId, 0);
        set Week := coalesce(Week, 0);

        drop table if exists temp_league_point_rules;

        create temporary table temp_league_point_rules
        select l.id as league_id, lpr.stat_type_id, lpr.multiplier, lpr.min_range, lpr.max_range, lpr.fixed_points
        from league_point_rules lpr
          left outer join leagues l on lpr.league_id is null
        where lpr.league_id is null
          and exists (select 1 from league_point_rules lpr2 where lpr2.league_id = l.id)
        ;

        update temp_league_point_rules tlpr, league_point_rules lpr
        set tlpr.multiplier = lpr.multiplier,
          tlpr.fixed_points = lpr.fixed_points
        where tlpr.league_id = lpr.league_id
          and tlpr.stat_type_id = lpr.stat_type_id
          and tlpr.min_range = lpr.min_range
          and tlpr.max_range = lpr.max_range
        ;

        delete lpp.* from league_player_points lpp
          inner join leagues l ON lpp.league_id = l.id
        where
          (SeasonId <= 0 or l.season_id = SeasonId)
          and (SeasonTypeId <= 0 or season_type_id = SeasonTypeId)
          and (Week <= 0 or nfl_week = Week);

        insert into league_player_points (league_id, nfl_game_player_id, player_id, season_type_id, nfl_week, points)
        select calc.league_id, gp.id, gp.nfl_player_id, calc.season_type_id, calc.week, sum(calc.points) as calc_points
        from (
          select l.id as league_id, gp.id, gp.nfl_player_id, g.season_type_id, g.week, gsm.value, lpr.fixed_points, lpr.multiplier, lpr.min_range, lpr.max_range,
            case lpr.fixed_points > 0 when true then lpr.fixed_points else gsm.value * lpr.multiplier end as points
          from nfl_game_stat_maps gsm
            inner join nfl_game_players gp on gsm.nfl_game_player_id = gp.id
            inner join nfl_games g on gp.nfl_game_id = g.id
            inner join temp_league_point_rules lpr on lpr.stat_type_id = gsm.stat_type_id
              and ( (lpr.min_range = 0 and lpr.max_range = 0) or (gsm.value >= lpr.min_range and gsm.value <= lpr.max_range) )
            inner join leagues l on lpr.league_id = l.id and l.season_id = g.season_id
          where
            (SeasonId <= 0 or g.season_id = SeasonId)
            and (SeasonTypeId <= 0 or g.season_type_id = SeasonTypeId)
            and (Week <= 0 or g.week = Week)
            and l.id = lpr.league_id
        ) calc
          inner join nfl_game_players gp on calc.id = gp.id
        group by calc.league_id, gp.id, gp.nfl_player_id, calc.season_type_id, calc.week, gp.points
        ;

        drop table if exists temp_league_point_rules;

        COMMIT;
      END;
    "
  end

  def down
    execute "DROP PROCEDURE IF EXISTS LoadLeaguePlayerPoints;"
    execute "DROP PROCEDURE IF EXISTS UpdateGamePlayerPoints;"
  end
end
