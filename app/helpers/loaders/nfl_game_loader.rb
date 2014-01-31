module Loaders
  class NflGameLoader < NflLoader
    #def load_games
    #  season = current_season
    #  games = load_json_data("/Schedules/#{season.year}", "#{season.year}/schedule.json", 86400)
    #  games_pre = load_json_data("/Schedules/#{season.year}PRE", "#{season.year}/PRE/schedule.json", 86400)
    #  games_post = load_json_data("/Schedules/#{season.year}POST", "#{season.year}/POST/schedule.json", 86400)
    #
    #  games += games_pre
    #  games += games_post
    #
    #  games.each do |game|
    #    home_team = get_team(game['HomeTeam'])
    #    away_team = get_team(game['AwayTeam'])
    #
    #    if(away_team.abbr == 'BYE')
    #      nfl_game = NflGame.find_or_create_by!(season_id: season.id, home_team_id: home_team.id, away_team_id: away_team.id)
    #    else
    #      nfl_game = NflGame.find_or_create_by!(external_game_id: game['GameKey'])
    #    end
    #
    #    nfl_game.home_team_id = home_team.id
    #    nfl_game.away_team_id = away_team.id
    #    nfl_game.start_time = convert_fantasy_data_time(game['Date'])
    #    nfl_game.season_id = season.id
    #    nfl_game.season_type_id = game['SeasonType']
    #    nfl_game.week = game['Week']
    #
    #    puts "Game data updated ExternalID #{nfl_game.external_game_id}, #{season.year}#{NflSeason.get_season_type_name(nfl_game.season_type_id)} Week #{nfl_game.week}, #{away_team.abbr} @#{home_team.abbr}" if nfl_game.changed?
    #
    #    nfl_game.save
    #  end
    #end

    def load_byes(season)
      byes = load_json_data("/Byes/#{season.year}", "#{season.year}/byes.json")
      away_team = get_team('BYE')
      nfl_games = NflGame.with_teams.find_season(season.year).where(away_team_id: away_team.id).readonly(false).to_a

      ActiveRecord::Base.transaction do
        byes.each do |item|
          home_team = get_team(item['Team'])

          nfl_game = nfl_games.find { |g| g.home_team_id == home_team.id }
          nfl_game = NflGame.find_or_create_by!(season_id: season.id, home_team_id: home_team.id, away_team_id: away_team.id) unless nfl_game

          nfl_game.week = item['Week']
          nfl_game.season_type_id = 1

          puts "Game data updated bye: #{season.year} Week #{nfl_game.week}, #{away_team.abbr} @#{home_team.abbr}" if nfl_game.changed?

          nfl_game.save
        end
      end
    end

    def get_game_scores(season)
      week = current_week

      scores_pre = load_json_data("/Scores/#{season.year}PRE", "#{season.year}/PRE/scores.json")

      if(week.to_i > 17)
        scores_reg = load_json_data("/Scores/#{season.year}", "#{season.year}/scores.json")
        scores_post = load_json_data("/Scores/#{season.year}POST", "#{season.year}/POST/scores.json", 30)
      else
        scores_reg = load_json_data("/Scores/#{season.year}", "#{season.year}/scores.json", 30)
        scores_post = []
      end

      scores = scores_pre + scores_reg + scores_post
      scores
    end
    private :get_game_scores

    def load_all
      load_current
    end

    def load_current
      season = current_season

      load_byes(season)
      games = get_game_scores(season)
      nfl_games = NflGame.with_teams.find_season(season.year).to_a

      ActiveRecord::Base.transaction do
        games.each do |game|
          nfl_game = nfl_games.find { |g| g.external_game_id == game["GameKey"] }
          unless nfl_game
            home_team = get_team(game['HomeTeam'])
            away_team = get_team(game['AwayTeam'])

            if(away_team.abbr == 'BYE')
              nfl_game = NflGame.find_or_create_by!(season_id: season.id, home_team_id: home_team.id, away_team_id: away_team.id)
            else
              nfl_game = NflGame.find_or_create_by!(external_game_id: game['GameKey'])
            end

            nfl_game.home_team_id = home_team.id
            nfl_game.away_team_id = away_team.id
            nfl_game.start_time = convert_fantasy_data_time(game['Date'])
            nfl_game.season_id = season.id
            nfl_game.season_type_id = game['SeasonType']
            nfl_game.week = game['Week']
          end

          home_team = get_team(game["HomeTeam"])
          away_team = get_team(game["AwayTeam"])

          puts "Mismatched HomeTeam DB: #{nfl_game.home_team.abbr}, JSON: #{home_team.abbr}" if nfl_game.home_team.abbr != home_team.abbr
          puts "Mismatched AwayTeam DB: #{nfl_game.away_team.abbr}, JSON: #{away_team.abbr}" if nfl_game.home_team.abbr != home_team.abbr
          puts "Mismatched GameWeek #{nfl_game.external_game_id} DB: #{nfl_game.week}, JSON: #{game['Week']}" if nfl_game.week != game['Week']

          nfl_game.has_started = game["HasStarted"]
          nfl_game.has_started_q1 = game["Has1stQuarterStarted"]
          nfl_game.has_started_q2 = game["Has2ndQuarterStarted"]
          nfl_game.has_started_q3 = game["Has3rdQuarterStarted"]
          nfl_game.has_started_q4 = game["Has4thQuarterStarted"]
          nfl_game.is_over = game["IsOver"]
          nfl_game.is_in_progress = game["IsInProgress"]
          nfl_game.is_overtime = game["IsOvertime"]
          nfl_game.away_score = game["AwayScore"]
          nfl_game.away_score_q1 = game["AwayScoreQuarter1"]
          nfl_game.away_score_q2 = game["AwayScoreQuarter2"]
          nfl_game.away_score_q3 = game["AwayScoreQuarter3"]
          nfl_game.away_score_q4 = game["AwayScoreQuarter4"]
          nfl_game.away_score_ot = game["AwayScoreOvertime"]
          nfl_game.home_score = game["HomeScore"]
          nfl_game.home_score_q1 = game["HomeScoreQuarter1"]
          nfl_game.home_score_q2 = game["HomeScoreQuarter2"]
          nfl_game.home_score_q3 = game["HomeScoreQuarter3"]
          nfl_game.home_score_q4 = game["HomeScoreQuarter4"]
          nfl_game.home_score_ot = game["HomeScoreOvertime"]
          nfl_game.quarter = game["Quarter"]
          nfl_game.down = game["AwayScore"]
          nfl_game.yards_to_go = game["Distance"]
          nfl_game.yard_line = game["YardLine"]
          nfl_game.time_remaining = game["TimeRemaining"]
          nfl_game.field_side = (game["YardLineTerritory"] == nfl_game.home_team.abbr)
          nfl_game.possession = (game["Possession"] == nfl_game.home_team.abbr)

          puts "Game data updated ExternalID #{nfl_game.external_game_id}, #{season.year}#{NflSeason.get_season_type_name(nfl_game.season_type_id)} Week #{nfl_game.week}, #{away_team.abbr} @#{home_team.abbr}" if nfl_game.changed?

          nfl_game.save
        end
      end

      return
    end
  end
end
