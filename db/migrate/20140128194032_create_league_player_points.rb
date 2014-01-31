class CreateLeaguePlayerPoints < ActiveRecord::Migration
  def up
    execute "DROP TABLE IF EXISTS league_player_points;"

    create_table :league_player_points, id: false do |t|
      t.integer :league_id
      t.integer :nfl_game_player_id
      t.integer :player_id
      t.integer :league_week
      t.integer :season_type_id
      t.integer :nfl_week
      t.decimal :points, precision: 10, scale: 4, null: false, default: 0

      t.timestamps
    end

    execute "ALTER TABLE league_player_points ADD PRIMARY KEY(league_id, season_type_id, nfl_week, player_id);"

    execute "DROP PROCEDURE IF EXISTS UpdateGamePlayerPoints;"
    execute "
      CREATE PROCEDURE UpdateGamePlayerPoints(
        IN SeasonTypeId integer,
        IN Week integer
      )
      BEGIN
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
            where (SeasonTypeId is null or g.season_type_id = SeasonTypeId)
              and (Week is null or g.week = Week)
            ) temp
            inner join nfl_game_players gp on temp.id = gp.id
            group by gp.id, gp.points
          ) calc
        set gp.points = calc.calc_points
        where gp.id = calc.id
        ;
      END;
    "

    execute "DROP PROCEDURE IF EXISTS LoadLeaguePlayerPoints;"
    execute "
      CREATE PROCEDURE LoadLeaguePlayerPoints(
        IN SeasonTypeId integer,
        IN Week integer
      )
      BEGIN
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

        delete from league_player_points
        where
          (SeasonTypeId is null or season_type_id = SeasonTypeId)
          and (Week is null or nfl_week = Week);

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
            inner join leagues l on lpr.league_id = l.id
          where (SeasonTypeId is null or g.season_type_id = SeasonTypeId)
            and (Week is null or g.week = Week)
            and l.id = lpr.league_id
        ) calc
          inner join nfl_game_players gp on calc.id = gp.id
        group by calc.league_id, gp.id, gp.nfl_player_id, calc.season_type_id, calc.week, gp.points
        ;

        drop table if exists temp_league_point_rules;
      END;
    "
  end

  def down
    execute "DROP PROCEDURE IF EXISTS LoadLeaguePlayerPoints;"
    execute "DROP PROCEDURE IF EXISTS UpdateGamePlayerPoints;"
    drop_table :league_player_points
  end
end
