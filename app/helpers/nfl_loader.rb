require 'thread'

class NflLoader
  include ApiHelper

  def current_season
    data = load_json_data('/CurrentSeason', 'current_season.json')
    season = NflSeason.find_or_create_by(year: data['data'])
  end

  def current_week
    data = load_json_data('/CurrentWeek', 'current_week.json')
    week = data['data']
  end

  def get_teams
    season = current_season.year
    items = load_json_data("/Teams/#{season}", "#{season}/teams.json")
  end
  private :get_teams

  def load_teams
    NflTeam.find_or_create_by!(name: 'BYE', abbr: 'BYE') #needed for bye weeks

    items = get_teams
    items.each do |item|
      # Creates team as needed or updates existing if data has changed
      team = NflTeam.find_or_create_by!(abbr: item['Key'])
      team.name = item['FullName']
      team.save
    end

    create_defense_players
  end

  def create_defense_players
    season = current_season

    NflTeam.where.not(abbr: 'BYE').each do |team|
      position = NflPosition.find_or_create_by(abbr: 'DEF')
      player = NflPlayer.find_or_create_by(external_player_id: "DEF_#{team.abbr}")
      player.first_name = team.name
      player.last_name = 'Defense'

      puts "NFL Player data updated ExternalID #{player.external_player_id}, #{player.full_name}" if player.changed?

      player.save

      seasonEntry = NflSeasonTeamPlayer.find_or_create_by(season_id: season.id, team_id: team.id, player_id: player.id, position_id: position.id)
      seasonEntry.player_number = 0

      puts "NFL SeasonTeamPlayer data updated #{player.full_name}, position #{position.abbr}, team #{team.abbr}" if seasonEntry.changed?

      seasonEntry.save
    end
  end

  def get_players(season)
    hash = Hash.new
    NflTeam.where.not(abbr: 'BYE').each { |team|
      items = load_json_data("/Players/#{team.abbr}", "#{season.year}/players/#{team.abbr}.json", 86400)
      hash[team] = items
    }
    hash
  end
  private :get_players

  def load_players
    season = current_season
    playersHash = get_players(season)
    playersHash.each { |team, playersData|
      puts "#{team.abbr} playersData: #{playersData.count}"

      players = Array.new
      playersData.each { |item|
        player = create_player(item, season, team)
        players.push(player)
      }

      puts "Positions: #{NflPosition.count}, NflSeasonTeamPlayer: #{NflSeasonTeamPlayer.where(team_id: team.id).count}"
    }
  end


  def load_player(season, external_player_id)
    item = load_json_data("/Player/#{external_player_id}", "#{season.year}/players/lookup/#{external_player_id}.json")
    create_player(item, season)
  end
  private :load_player

  def create_player(item, season, team = nil)
    position = NflPosition.find_or_create_by(abbr: item['FantasyPosition'])
    player = NflPlayer.find_or_create_by(external_player_id: item['PlayerID'])
    player.first_name = item['FirstName']
    player.last_name = item['LastName']
    player.photo_url = item['PhotoUrl']

    puts "NFL Player data updated ExternalID #{player.external_player_id}, #{player.full_name}" if player.changed?

    player.save

    team = get_team(item['Team']) unless team

    seasonEntry = NflSeasonTeamPlayer.find_or_create_by(season_id: season.id, team_id: team.id, player_id: player.id, position_id: position.id)
    # current_team_abbr: item['CurrentTeam'],
    seasonEntry.player_number = item['Number']

    puts "NFL SeasonTeamPlayer data updated #{player.full_name}, position #{position.abbr}, team #{team.abbr}" if seasonEntry.changed?

    seasonEntry.save

    player
  end
  private :create_player

  def load_games
    season = current_season
    games = load_json_data("/Schedules/#{season.year}", "#{season.year}/schedule.json")

    games.each do |game|
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
      nfl_game.week = game['Week']

      puts "Game data updated ExternalID #{nfl_game.external_game_id}, Week #{nfl_game.week}, #{nfl_game.away_team.abbr} @#{nfl_game.home_team.abbr}" if nfl_game.changed?

      nfl_game.save
    end
  end

  def get_game_scores
    season = current_season.year
    # load_json_data("/Scores/#{season}", "#{season}/scores.json", 30)
    load_json_data("/Scores/#{season}", "#{season}/scores.json")
  end
  private :get_game_scores

  def load_game_scores
    games = get_game_scores
    games.each do |game|
      nfl_game = NflGame.find_by!(external_game_id: game["GameKey"])

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

      puts "Game data updated ExternalID #{nfl_game.external_game_id}, Week #{nfl_game.week}, #{nfl_game.away_team.abbr} @#{nfl_game.home_team.abbr}" if nfl_game.changed?

      nfl_game.save
    end
  end

  def load_defense_stats(season, week, cache_timeout)
    items = load_json_data("/FantasyDefenseByGame/#{season}/#{week}", "#{season}/weeks/#{week}/stats_defense.json", cache_timeout)
    stat_types = get_stat_types

    items.each do |item|
      player = NflPlayer.find_by!(external_player_id: "DEF_#{item['Team']}")
      nfl_game = get_nfl_game item['GameKey']
      next unless nfl_game

      team = get_team(item['Team'])
      position = get_position('DEF')

      game_player = update_game_player(nfl_game, player, team, position)

      stat_types.each { |stat_type|
        next unless (item[stat_type.name])
        $player_stat_sql.push "(#{game_player.id}, #{stat_type.id}, #{item[stat_type.name]})"
      }
    end
  end

  def get_player_stats(season, week, cache_timeout = 0)
    load_json_data("/PlayerGameStatsByWeek/#{season}/#{week}", "#{season}/weeks/#{week}/stats.json", cache_timeout)
  end
  private :get_player_stats

  def get_team(abbr)
    # Cache NFLTeams to minimize DB hits
    unless $nfl_teams
      Thread.exclusive {
        unless $nfl_teams
          $nfl_teams = NflTeam.all.to_ary
        end
      }
    end
    team = $nfl_teams.find { |i| i.abbr == abbr }
    puts "Team not found in DB: #{abbr}" unless team
    team
  end

  def get_position(abbr)
    # Cache NFLPositions to minimize DB hits
    unless $nfl_positions
      Thread.exclusive {
        unless $nfl_positions
          $nfl_positions = NflPosition.all.to_ary
        end
      }
    end
    position = $nfl_positions.find { |i| i.abbr == abbr }
    # puts "Position not found in DB: #{abbr}" unless position
    position
  end

  def get_nfl_game(external_game_id)
    # Cache NFLGames to minimize DB hits
    nfl_game = $nfl_games[external_game_id]
    Thread.exclusive {
      nfl_game = $nfl_games[external_game_id]
      unless(nfl_game)
        nfl_game = NflGame.find_by!(external_game_id: external_game_id)
        $nfl_games[external_game_id] = nfl_game
      end
    }
    puts "Game not found in DB ExternalID: #{external_game_id}" unless nfl_game
    nfl_game
  end

  def get_stat_types
    # Cache StatTypes to minimize DB hits
    unless $stat_types
      Thread.exclusive {
        unless $stat_types
          $stat_types = StatType.all.to_ary
        end
      }
    end

    $stat_types
  end

  def load_player_stats(season, week, cache_timeout = 0)
    get_start = Time.now
    players = get_player_stats(season.year, week, cache_timeout)

    $players = players
    $nfl_games = Hash.new
    $player_stat_sql = Array.new

    threads = Array.new
    for i in 1..3
      t = Thread.new { thread_process_player_stats(season, week) }
      t["name"] = i
      threads.push(t)
    end

    threads.each do |t|
      t.join
    end

    load_defense_stats(season.year, week, cache_timeout)

    puts "Week #{week}: loading time taken: #{Time.now - get_start}"

    get_start = Time.now
    NflGameStatMap.transaction do
      sql_array = Array.new

      game_ids = $nfl_games.values.map { |v| v.id }.join(',')
      sql_array.push "
        delete
        from nfl_game_stat_maps
        where nfl_game_player_id in (
          select gp.id
          from nfl_game_players gp
            inner join nfl_games g on gp.nfl_game_id = g.id
          where g.id in (#{game_ids})
        )
      "

      while $player_stat_sql.size > 0 do
        statements = $player_stat_sql.slice!(0, 100000)
        inserts = statements.join(",\n    ")
        sql_array.push "INSERT INTO nfl_game_stat_maps (nfl_game_player_id, stat_type_id, value) VALUES #{inserts};"
      end

      sql_array.each { |sql|
        begin
          NflGameStatMap.connection.execute(sql)
        rescue Exception => e
          puts e.message[0,400]
          puts e.backtrace.join("\n   ")
          raise ActiveRecord::Rollback
          break
        end
      }
    end

    puts "Week #{week}: SQL time taken: #{Time.now - get_start}"
  end
  private :load_player_stats

  def thread_process_player_stats(season, week)
    Thread.exclusive {
      # Gets around issue error in autoload activerecord objects
      NflSeasonTeamPlayer
      NflPlayer
    }

    while $players.count > 0
      item = nil
      Thread.exclusive {
        item = $players.pop
        # puts "Thread #{Thread.current["name"]} processing, players remaining #{$players.count}"
      }
      player = process_player_stats(season, week, item) if item
      # puts "Thread #{Thread.current["name"]} processed ID #{player.id}, #{player.full_name}"
    end

    ActiveRecord::Base.connection.close   # Release any DB connections used by the current thread
  end
  private :thread_process_player_stats

  def update_game_player(nfl_game, player, team, position)
    game_player = NflGamePlayer.find_or_create_by(nfl_game_id: nfl_game.id, nfl_player_id: player.id)
    game_player.nfl_team_id = team.id
    game_player.nfl_position_id = position.id

    puts "GamePlayer data updated ExternalID #{nfl_game.external_game_id}, Player #{player.full_name}, Team #{team.abbr}, Position #{position.abbr}" if game_player.changed?

    game_player.save
    game_player
  end

  def process_player_stats(season, week, item)
    player = NflPlayer.find_by(external_player_id: item['PlayerID'])
    unless player
      puts "Player not found in DB ExternalID: #{item['PlayerID']}, Team: #{item['Team']}, Name: #{item['Name']}... retrying"

      if(item['PlayerID'])
        player = load_player(season, item['PlayerID'])
        puts "Found player in DB ExternalID: #{player.external_player_id}, Name: #{player.full_name}" if player
      else
        team = get_team(item['Team'])
        team_player = NflSeasonTeamPlayer.find_by(season_id: season.id, team_id: team.id, player_number: item['Number'])
        if(team_player)
          player = NflPlayer.find_by(id: team_player.player_id)
          puts "Found player in DB ExternalID: #{player.external_player_id}, Name: #{player.full_name}, Number: #{team_player.player_number}" if player
        end
      end

      puts "Player not found in DB ExternalID: #{item['PlayerID']}, Team: #{item['Team']}, Name: #{item['Name']}" unless player
    end

    nfl_game = get_nfl_game item['GameKey']

    return unless player && nfl_game

    team = get_team(item['Team'])
    position = get_position(item['Position'])

    return unless team && position

    game_player = update_game_player(nfl_game, player, team, position)

    stat_types = get_stat_types

    stat_types.each { |stat_type|
      next unless (item[stat_type.name])
      $player_stat_sql.push "(#{game_player.id}, #{stat_type.id}, #{item[stat_type.name]})"
    }

    player
  end
  private :load_player_stats

  def load_all_player_stats
    season = current_season
    week = current_week
    for i in 1..week.to_i
      players = load_player_stats(season, i)
    end
  end

  def load_current_player_stats
    load_current_player_stats_thread_test
    return
    season = current_season
    week = current_week
    load_player_stats(season, week)
  end

  def load_current_player_stats_thread_test
    season = current_season
    week = current_week

    game = NflGame.find_by(season_id: season.id, week: week)
    game_player = NflGamePlayer.find_by(nfl_game_id: game.id)
    test = NflGameStatMap.where(nfl_game_player_id: game_player.id).first

    t1 = Thread.new { load_player_stats(season, week) }

    if test
      test.value = 666
      test.save

      threads = Array.new
      for i in 1..5 do
        threads.push Thread.new {
          Thread.exclusive {
            NflSeasonTeamPlayer
            NflGameStatMap
          }

          for i in 1..20 do
            test = NflGameStatMap.where(nfl_game_player_id: game_player.id).first
            puts test.inspect
            sleep(0.4)
          end
        }
      end
      threads.each do |thread|
        thread.join
      end
    end

    t1.join
  end

  def convert_fantasy_data_time(epoch_time)
    time = epoch_time.match(/\d+/)[0]
    fail "Could not convert from epoch time" unless time
    Time.at(time.to_i / 1000)
  end
end
